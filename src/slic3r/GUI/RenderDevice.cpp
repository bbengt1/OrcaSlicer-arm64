#include "RenderDevice.hpp"

namespace Slic3r {
namespace GUI {

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

private:
    Info m_info;
};

} // namespace

std::unique_ptr<RenderDevice> RenderDevice::create(RendererBackend backend)
{
    return std::make_unique<NullRenderDevice>(backend);
}

} // namespace GUI
} // namespace Slic3r
