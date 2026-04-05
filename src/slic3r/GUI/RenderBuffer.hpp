#ifndef slic3r_RenderBuffer_hpp_
#define slic3r_RenderBuffer_hpp_

#include <cstddef>
#include <cstdint>
#include <memory>
#include <vector>

#include "RenderBackend.hpp"

namespace Slic3r {
namespace GUI {

class RenderBuffer
{
public:
    enum class Usage : unsigned char
    {
        Static,
        Dynamic
    };

    struct Descriptor
    {
        RendererBackend backend { RendererBackend::OpenGL };
        Usage usage { Usage::Static };
        std::size_t size_bytes { 0 };
    };

    virtual ~RenderBuffer() = default;

    virtual const Descriptor& descriptor() const = 0;
    virtual bool upload(const void* data, std::size_t size_bytes) = 0;
    virtual void* native_handle() const = 0;

    bool valid() const { return descriptor().size_bytes > 0 && native_handle() != nullptr; }

    static std::unique_ptr<RenderBuffer> create(const Descriptor& descriptor);
};

template <typename T>
inline std::unique_ptr<RenderBuffer> create_render_buffer(RendererBackend backend, const std::vector<T>& data, RenderBuffer::Usage usage = RenderBuffer::Usage::Static)
{
    RenderBuffer::Descriptor descriptor;
    descriptor.backend = backend;
    descriptor.usage = usage;
    descriptor.size_bytes = data.size() * sizeof(T);

    auto buffer = RenderBuffer::create(descriptor);
    if (buffer != nullptr && !data.empty())
        buffer->upload(data.data(), descriptor.size_bytes);
    return buffer;
}

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_RenderBuffer_hpp_
