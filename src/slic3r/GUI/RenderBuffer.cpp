#include "RenderBuffer.hpp"

namespace Slic3r {
namespace GUI {

#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
std::unique_ptr<RenderBuffer> create_metal_render_buffer(const RenderBuffer::Descriptor& descriptor);
#endif

namespace {

class NullRenderBuffer final : public RenderBuffer
{
public:
    explicit NullRenderBuffer(Descriptor descriptor)
        : m_descriptor(descriptor)
    {
    }

    const Descriptor& descriptor() const override { return m_descriptor; }
    bool upload(const void*, std::size_t) override { return false; }
    void* native_handle() const override { return nullptr; }

private:
    Descriptor m_descriptor;
};

} // namespace

std::unique_ptr<RenderBuffer> RenderBuffer::create(const Descriptor& descriptor)
{
#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
    if (descriptor.backend == RendererBackend::Metal)
        return create_metal_render_buffer(descriptor);
#endif

    return std::make_unique<NullRenderBuffer>(descriptor);
}

} // namespace GUI
} // namespace Slic3r
