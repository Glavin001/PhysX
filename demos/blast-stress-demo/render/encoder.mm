// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause

#include "encoder.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

#include <string>

namespace wall_render
{
namespace
{
std::string describe(NSError* error)
{
    if (error == nil)
    {
        return "unknown error";
    }
    return std::string([[error localizedDescription] UTF8String] ?: "unknown error");
}
} // namespace

struct Encoder::State
{
    AVAssetWriter* writer{nil};
    AVAssetWriterInput* input{nil};
    AVAssetWriterInputPixelBufferAdaptor* adaptor{nil};
    CVPixelBufferPoolRef pool{nullptr};
    CVMetalTextureCacheRef textures{nullptr};
    id<MTLDevice> device{nil};
    std::uint32_t width{0};
    std::uint32_t height{0};
    std::uint32_t fps{60};
    bool started{false};

    ~State()
    {
        if (pool != nullptr)
        {
            CVPixelBufferPoolRelease(pool);
        }
        if (textures != nullptr)
        {
            CFRelease(textures);
        }
    }
};

Encoder::Encoder() : m_state(std::make_unique<State>()) {}

Encoder::~Encoder() = default;

bool Encoder::fail(const std::string& message)
{
    if (m_error.empty())
    {
        m_error = message;
    }
    return false;
}

bool Encoder::open(id<MTLDevice> device, const EncoderOptions& options)
{
    if (m_state->writer != nil)
    {
        return fail("encoder is already open");
    }
    if (device == nil || options.width == 0 || options.height == 0 || options.fps == 0)
    {
        return fail("encoder requires a device and a non-empty frame size");
    }
    // H.264 4:2:0 cannot represent odd dimensions; refuse rather than silently
    // letting the encoder round and desynchronize the declared resolution.
    if ((options.width % 2) != 0 || (options.height % 2) != 0)
    {
        return fail("encoder frame size must be even in both axes");
    }

    @autoreleasepool
    {
        m_state->device = device;
        m_state->width = options.width;
        m_state->height = options.height;
        m_state->fps = options.fps;

        NSString* path = [NSString stringWithUTF8String:options.path.c_str()];
        NSURL* url = [NSURL fileURLWithPath:path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            // Never overwrite: captures and their videos are evidence.
            return fail("encoder output already exists: " + options.path);
        }

        NSError* error = nil;
        m_state->writer = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeMPEG4 error:&error];
        if (m_state->writer == nil)
        {
            return fail("cannot create asset writer: " + describe(error));
        }

        NSDictionary* compression = @{
            AVVideoQualityKey : @(options.quality),
            AVVideoExpectedSourceFrameRateKey : @(options.fps),
            AVVideoMaxKeyFrameIntervalKey : @(options.fps * 2),
        };
        NSDictionary* settings = @{
            AVVideoCodecKey : options.hevc ? AVVideoCodecTypeHEVC : AVVideoCodecTypeH264,
            AVVideoWidthKey : @(options.width),
            AVVideoHeightKey : @(options.height),
            AVVideoCompressionPropertiesKey : compression,
            // State the colour space rather than leaving players to guess; the
            // shader writes sRGB-encoded values into the surface.
            AVVideoColorPropertiesKey : @{
                AVVideoColorPrimariesKey : AVVideoColorPrimaries_ITU_R_709_2,
                AVVideoTransferFunctionKey : AVVideoTransferFunction_ITU_R_709_2,
                AVVideoYCbCrMatrixKey : AVVideoYCbCrMatrix_ITU_R_709_2,
            },
        };

        m_state->input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                            outputSettings:settings];
        // Offline encoding: let the encoder apply back-pressure instead of
        // dropping frames to keep up with a wall clock.
        m_state->input.expectsMediaDataInRealTime = NO;
        if (![m_state->writer canAddInput:m_state->input])
        {
            return fail("asset writer rejected the video input settings");
        }
        [m_state->writer addInput:m_state->input];

        NSDictionary* surface = @{
            (NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
            (NSString*)kCVPixelBufferWidthKey : @(options.width),
            (NSString*)kCVPixelBufferHeightKey : @(options.height),
            (NSString*)kCVPixelBufferMetalCompatibilityKey : @YES,
            (NSString*)kCVPixelBufferIOSurfacePropertiesKey : @{},
        };
        m_state->adaptor =
            [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:m_state->input
                                                                          sourcePixelBufferAttributes:surface];

        if (CVPixelBufferPoolCreate(kCFAllocatorDefault, nullptr, (__bridge CFDictionaryRef)surface,
                                    &m_state->pool) != kCVReturnSuccess)
        {
            return fail("cannot create the shared pixel buffer pool");
        }
        if (CVMetalTextureCacheCreate(kCFAllocatorDefault, nullptr, device, nullptr, &m_state->textures)
            != kCVReturnSuccess)
        {
            return fail("cannot create the Metal texture cache");
        }

        if (![m_state->writer startWriting])
        {
            return fail("asset writer refused to start: " + describe(m_state->writer.error));
        }
        [m_state->writer startSessionAtSourceTime:kCMTimeZero];
        m_state->started = true;
    }
    return true;
}

bool Encoder::acquire(EncoderFrame& frame)
{
    if (!m_state->started)
    {
        return fail("encoder is not open");
    }
    @autoreleasepool
    {
        CVPixelBufferRef buffer = nullptr;
        if (CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, m_state->pool, &buffer) != kCVReturnSuccess
            || buffer == nullptr)
        {
            return fail("pixel buffer pool exhausted");
        }

        CVMetalTextureRef reference = nullptr;
        // BGRA8Unorm_sRGB so the hardware encodes the sRGB transfer on write and
        // the surface holds display-referred values, matching the colour tags.
        const CVReturn created = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault, m_state->textures, buffer, nullptr, MTLPixelFormatBGRA8Unorm_sRGB,
            m_state->width, m_state->height, 0, &reference);
        if (created != kCVReturnSuccess || reference == nullptr)
        {
            CVPixelBufferRelease(buffer);
            return fail("cannot alias the pixel buffer as a Metal texture");
        }

        frame.pixelBuffer = buffer;
        frame.textureReference = (void*)reference;
        frame.texture = CVMetalTextureGetTexture(reference);
        if (frame.texture == nil)
        {
            CFRelease(reference);
            CVPixelBufferRelease(buffer);
            return fail("texture cache returned no texture");
        }
    }
    return true;
}

bool Encoder::submit(const EncoderFrame& frame, std::uint64_t index)
{
    if (!m_state->started)
    {
        return fail("encoder is not open");
    }
    if (frame.pixelBuffer == nullptr)
    {
        return fail("submitted an empty frame");
    }

    CVPixelBufferRef buffer = static_cast<CVPixelBufferRef>(frame.pixelBuffer);
    bool ok = true;
    @autoreleasepool
    {
        // Back-pressure: the encoder is deliberately allowed to stall us.
        while (!m_state->input.readyForMoreMediaData)
        {
            if (m_state->writer.status == AVAssetWriterStatusFailed)
            {
                ok = fail("encoder failed while waiting: " + describe(m_state->writer.error));
                break;
            }
            [NSThread sleepForTimeInterval:0.0005];
        }

        if (ok)
        {
            const CMTime when = CMTimeMake(static_cast<int64_t>(index), static_cast<int32_t>(m_state->fps));
            if (![m_state->adaptor appendPixelBuffer:buffer withPresentationTime:when])
            {
                ok = fail("encoder rejected a frame: " + describe(m_state->writer.error));
            }
            else
            {
                ++m_submitted;
            }
        }
    }
    // The texture's owner outlives the encode, not just the extraction.
    if (frame.textureReference != nullptr)
    {
        CFRelease((CVMetalTextureRef)frame.textureReference);
    }
    CVPixelBufferRelease(buffer);
    return ok;
}

bool Encoder::finish()
{
    if (!m_state->started)
    {
        return fail("encoder is not open");
    }
    __block bool done = false;
    @autoreleasepool
    {
        [m_state->input markAsFinished];
        [m_state->writer finishWritingWithCompletionHandler:^{
            done = true;
        }];
        while (!done)
        {
            [NSThread sleepForTimeInterval:0.001];
        }
        if (m_state->writer.status != AVAssetWriterStatusCompleted)
        {
            return fail("encoder did not finalize: " + describe(m_state->writer.error));
        }
        m_state->started = false;
    }
    return true;
}

} // namespace wall_render
