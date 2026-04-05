#include "RenderTexture.hpp"

namespace Slic3r {
namespace GUI {

#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
std::unique_ptr<RenderTexture> create_metal_render_texture(const RenderTexture::Descriptor& descriptor);
#endif

namespace {

class NullRenderTexture final : public RenderTexture
{
public:
    explicit NullRenderTexture(Descriptor descriptor)
        : m_descriptor(descriptor)
    {
    }

    const Descriptor& descriptor() const override { return m_descriptor; }
    bool upload_rgba8(const void*, std::size_t) override { return false; }
    void* native_handle() const override { return nullptr; }

private:
    Descriptor m_descriptor;
};

} // namespace

std::unique_ptr<RenderTexture> RenderTexture::create(const Descriptor& descriptor)
{
#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
    if (descriptor.backend == RendererBackend::Metal)
        return create_metal_render_texture(descriptor);
#endif

    return std::make_unique<NullRenderTexture>(descriptor);
}

} // namespace GUI
} // namespace Slic3r
