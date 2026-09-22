// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// Reads the TWSTATE1 trajectory written by state_writer.cpp. First C++ reader of
// the format; the Rust recorder has the other one.
//
// Playback is sequential and keeps only the current frame resident, because the
// format is delta-encoded: a frame record carries just the poses that changed,
// and everything else deliberately retains its previous value. Materializing
// every frame would defeat the point — thousands of bodies over minutes of
// footage is gigabytes dense, and a few hundred megabytes as written.
#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace wall_render
{

struct Camera
{
    float eye[3]{0, 0, 0};
    float direction[3]{0, 0, -1};
    float fovDegrees{55};
};

struct Actor
{
    enum Shape : std::uint8_t
    {
        Box = 1,
        Sphere = 2,
        Mesh = 3
    };

    std::uint8_t part{0};
    std::uint8_t shape{Box};
    float parameters[3]{0.5f, 0.5f, 0.5f};
    float localPose[7]{0, 0, 0, 0, 0, 0, 1};
    // Only populated for Shape::Mesh; positions and normals are parallel.
    std::vector<float> meshPositions;
    std::vector<float> meshNormals;
    std::vector<std::uint32_t> meshIndices;
};

struct Pose
{
    float position[3]{0, 0, 0};
    float rotation[4]{0, 0, 0, 1};
    std::uint8_t sleeping{0};
    std::uint32_t group{0xFFFFFFFFu};
};

class Trajectory
{
public:
    Trajectory();
    ~Trajectory();

    Trajectory(const Trajectory&) = delete;
    Trajectory& operator=(const Trajectory&) = delete;

    bool open(const std::string& path);

    // Rewinds to before the first frame; poses reset to the identity state.
    void rewind();

    // Applies the next frame record. Returns false at the end of the stream.
    bool advance();

    // Dense state after the most recent advance(), one entry per actor.
    const std::vector<Pose>& poses() const { return m_poses; }
    std::uint32_t frameIndex() const { return m_frameIndex; }

    const std::vector<Actor>& actors() const { return m_actors; }
    const std::vector<Camera>& cameras() const { return m_cameras; }
    std::uint32_t fps() const { return m_fps; }
    // Frame count declared in the header. A truncated run can record fewer; the
    // caller should compare against how many advance() calls actually succeed.
    std::uint32_t declaredFrames() const { return m_declaredFrames; }
    std::uint32_t recordedFrames() const { return std::uint32_t(m_frameOffsets.size()); }
    bool terminated() const { return m_terminated; }
    const std::string& error() const { return m_error; }

private:
    bool fail(const std::string& message);

    const std::uint8_t* m_data{nullptr};
    std::size_t m_size{0};
    std::size_t m_mapped{0};

    std::uint32_t m_version{0};
    std::uint32_t m_fps{60};
    std::uint32_t m_declaredFrames{0};
    bool m_terminated{false};

    std::vector<Actor> m_actors;
    std::vector<Camera> m_cameras;
    std::vector<std::size_t> m_frameOffsets;
    std::vector<Pose> m_poses;
    std::size_t m_cursor{0};
    std::uint32_t m_frameIndex{0};
    std::string m_error;
};

} // namespace wall_render
