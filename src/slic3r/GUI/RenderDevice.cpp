#include "RenderDevice.hpp"

namespace Slic3r {
namespace GUI {

#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
std::unique_ptr<RenderDevice> create_metal_render_device();
#endif

namespace {

class NullRenderDevice final : public RenderDevice
{
public:
    explicit NullRenderDevice(RendererBackend backend)
    {
        m_info.backend = backend;
        m_info.renderer_name = renderer_backend_display_name(backend);
        m_info.device_name = "Unavailable";
        m_info.available = false;
    }

    const Info& info() const override { return m_info; }
    void* native_device_handle() const override { return nullptr; }
    void* native_command_queue_handle() const override { return nullptr; }

private:
    Info m_info;
};

} // namespace

std::unique_ptr<RenderDevice> RenderDevice::create(RendererBackend backend)
{
#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
    if (backend == RendererBackend::Metal)
        return create_metal_render_device();
#endif

    return std::make_unique<NullRenderDevice>(backend);
}

} // namespace GUI
} // namespace Slic3r
