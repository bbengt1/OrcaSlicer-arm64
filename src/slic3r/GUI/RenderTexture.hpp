#ifndef slic3r_RenderTexture_hpp_
#define slic3r_RenderTexture_hpp_

#include <cstddef>
#include <cstdint>
#include <memory>
#include <vector>

#include "RenderBackend.hpp"

namespace Slic3r {
namespace GUI {

class RenderTexture
{
public:
    enum class PixelFormat : unsigned char
    {
        RGBA8
    };

    struct Descriptor
    {
        RendererBackend backend { RendererBackend::OpenGL };
        PixelFormat format { PixelFormat::RGBA8 };
        int width { 0 };
        int height { 0 };
    };

    virtual ~RenderTexture() = default;

    virtual const Descriptor& descriptor() const = 0;
    virtual bool upload_rgba8(const void* data, std::size_t size_bytes) = 0;
    virtual void* native_handle() const = 0;

    bool valid() const { return descriptor().width > 0 && descriptor().height > 0 && native_handle() != nullptr; }

    static std::unique_ptr<RenderTexture> create(const Descriptor& descriptor);
};

inline std::unique_ptr<RenderTexture> create_render_texture(RendererBackend backend, int width, int height, const std::vector<std::uint8_t>& rgba8)
{
    RenderTexture::Descriptor descriptor;
    descriptor.backend = backend;
    descriptor.width = width;
    descriptor.height = height;

    auto texture = RenderTexture::create(descriptor);
    if (texture != nullptr && !rgba8.empty())
        texture->upload_rgba8(rgba8.data(), rgba8.size());
    return texture;
}

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_RenderTexture_hpp_
