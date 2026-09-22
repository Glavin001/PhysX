// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause

#include "twstate_reader.h"

#include <cstring>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

namespace wall_render
{
namespace
{
constexpr std::uint8_t kRecordActor = 1;
constexpr std::uint8_t kRecordFrame = 2;
constexpr std::uint8_t kRecordEnd = 255;

// A bounds-checked cursor. Every read is validated because a truncated or
// corrupt trajectory must be rejected, never silently desynchronized into
// plausible-looking garbage poses.
struct Cursor
{
    const std::uint8_t* data;
    std::size_t size;
    std::size_t at;
    bool ok{true};

    bool take(void* destination, std::size_t count)
    {
        if (!ok || at + count > size)
        {
            ok = false;
            return false;
        }
        std::memcpy(destination, data + at, count);
        at += count;
        return true;
    }

    std::uint8_t u8()
    {
        std::uint8_t value = 0;
        take(&value, sizeof(value));
        return value;
    }

    std::uint32_t u32()
    {
        std::uint32_t value = 0;
        take(&value, sizeof(value));
        return value;
    }

    float f32()
    {
        float value = 0;
        take(&value, sizeof(value));
        return value;
    }
};
} // namespace

Trajectory::Trajectory() = default;

Trajectory::~Trajectory()
{
    if (m_data != nullptr && m_mapped != 0)
    {
        ::munmap(const_cast<std::uint8_t*>(m_data), m_mapped);
    }
}

bool Trajectory::fail(const std::string& message)
{
    if (m_error.empty())
    {
        m_error = message;
    }
    return false;
}

bool Trajectory::open(const std::string& path)
{
    const int file = ::open(path.c_str(), O_RDONLY);
    if (file < 0)
    {
        return fail("cannot open trajectory: " + path);
    }
    struct stat info
    {
    };
    if (::fstat(file, &info) != 0 || info.st_size <= 0)
    {
        ::close(file);
        return fail("cannot size trajectory: " + path);
    }
    void* mapped = ::mmap(nullptr, std::size_t(info.st_size), PROT_READ, MAP_PRIVATE, file, 0);
    ::close(file);
    if (mapped == MAP_FAILED)
    {
        return fail("cannot map trajectory: " + path);
    }
    m_data = static_cast<const std::uint8_t*>(mapped);
    m_size = std::size_t(info.st_size);
    m_mapped = m_size;

    Cursor cursor{m_data, m_size, 0};
    char magic[8]{};
    if (!cursor.take(magic, sizeof(magic)) || std::memcmp(magic, "TWSTATE1", 8) != 0)
    {
        return fail("not a TWSTATE1 trajectory");
    }
    m_version = cursor.u32();
    if (m_version != 2 && m_version != 3)
    {
        return fail("unsupported trajectory version");
    }
    m_fps = cursor.u32();
    m_declaredFrames = cursor.u32();
    cursor.u32(); // pane width, a recorder mosaic concern
    cursor.u32(); // pane height
    cursor.u32(); // building count, informational
    const std::uint32_t cameraCount = cursor.u32();
    cursor.f32(); // duration
    cursor.f32(); // settle
    if (!cursor.ok || m_fps == 0)
    {
        return fail("trajectory header is truncated");
    }
    if (cameraCount > 64)
    {
        return fail("implausible camera count");
    }
    m_cameras.resize(cameraCount);
    for (Camera& camera : m_cameras)
    {
        for (float& value : camera.eye) value = cursor.f32();
        for (float& value : camera.direction) value = cursor.f32();
        camera.fovDegrees = cursor.f32();
    }
    if (!cursor.ok)
    {
        return fail("trajectory cameras are truncated");
    }

    while (cursor.ok && cursor.at < cursor.size)
    {
        const std::size_t recordStart = cursor.at;
        const std::uint8_t tag = cursor.u8();
        if (tag == kRecordEnd)
        {
            m_terminated = true;
            break;
        }
        if (tag == kRecordActor)
        {
            const std::uint32_t id = cursor.u32();
            const std::uint8_t part = cursor.u8();
            const std::uint32_t shapeCount = cursor.u32();
            if (!cursor.ok || id != m_actors.size())
            {
                return fail("actor ids must be contiguous from zero");
            }
            Actor actor;
            actor.part = part;
            for (std::uint32_t s = 0; s < shapeCount; ++s)
            {
                const std::uint8_t shape = cursor.u8();
                float parameters[3]{};
                for (float& value : parameters) value = cursor.f32();
                float local[7]{};
                for (float& value : local) value = cursor.f32();
                if (s == 0)
                {
                    actor.shape = shape;
                    std::memcpy(actor.parameters, parameters, sizeof(parameters));
                    std::memcpy(actor.localPose, local, sizeof(local));
                }
                if (shape == Actor::Mesh)
                {
                    const std::uint32_t vertices = cursor.u32();
                    if (!cursor.ok || vertices > (1u << 24))
                    {
                        return fail("implausible mesh vertex count");
                    }
                    std::vector<float> positions(std::size_t(vertices) * 3);
                    std::vector<float> normals(std::size_t(vertices) * 3);
                    for (std::uint32_t v = 0; v < vertices; ++v)
                    {
                        for (int k = 0; k < 3; ++k) positions[v * 3 + k] = cursor.f32();
                        for (int k = 0; k < 3; ++k) normals[v * 3 + k] = cursor.f32();
                    }
                    const std::uint32_t indexCount = cursor.u32();
                    if (!cursor.ok || indexCount > (1u << 26))
                    {
                        return fail("implausible mesh index count");
                    }
                    std::vector<std::uint32_t> indices(indexCount);
                    for (std::uint32_t i = 0; i < indexCount; ++i) indices[i] = cursor.u32();
                    if (s == 0)
                    {
                        actor.meshPositions = std::move(positions);
                        actor.meshNormals = std::move(normals);
                        actor.meshIndices = std::move(indices);
                    }
                }
                else if (shape != Actor::Box && shape != Actor::Sphere)
                {
                    return fail("unknown actor shape");
                }
            }
            if (!cursor.ok)
            {
                return fail("actor record is truncated");
            }
            m_actors.push_back(std::move(actor));
            continue;
        }
        if (tag != kRecordFrame)
        {
            return fail("unknown trajectory record");
        }
        // Index the frame and skip its payload; playback revisits it later.
        cursor.u32(); // frame index
        const std::uint32_t updates = cursor.u32();
        if (!cursor.ok)
        {
            return fail("frame record is truncated");
        }
        const std::size_t stride = 4 + 28 + 1 + (m_version >= 3 ? 4 : 0);
        const std::size_t payload = std::size_t(updates) * stride;
        if (cursor.at + payload > cursor.size)
        {
            return fail("frame payload extends past the end of the trajectory");
        }
        cursor.at += payload;
        m_frameOffsets.push_back(recordStart);
    }
    if (!cursor.ok)
    {
        return fail("trajectory is truncated");
    }
    if (m_actors.empty())
    {
        return fail("trajectory declares no actors");
    }
    rewind();
    return true;
}

void Trajectory::rewind()
{
    m_poses.assign(m_actors.size(), Pose{});
    m_cursor = 0;
    m_frameIndex = 0;
}

bool Trajectory::advance()
{
    if (m_cursor >= m_frameOffsets.size())
    {
        return false;
    }
    Cursor cursor{m_data, m_size, m_frameOffsets[m_cursor]};
    cursor.u8(); // record tag, already validated during indexing
    m_frameIndex = cursor.u32();
    const std::uint32_t updates = cursor.u32();
    for (std::uint32_t u = 0; u < updates; ++u)
    {
        const std::uint32_t id = cursor.u32();
        Pose pose;
        for (float& value : pose.position) value = cursor.f32();
        for (float& value : pose.rotation) value = cursor.f32();
        pose.sleeping = cursor.u8();
        pose.group = m_version >= 3 ? cursor.u32() : 0xFFFFFFFFu;
        if (!cursor.ok || id >= m_poses.size())
        {
            m_error = "frame updates an undeclared actor";
            return false;
        }
        // Actors absent from this record keep their previous pose by design.
        m_poses[id] = pose;
    }
    ++m_cursor;
    return cursor.ok;
}

} // namespace wall_render
