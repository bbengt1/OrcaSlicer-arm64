#include "RenderDevice.hpp"

#import <Metal/Metal.h>

namespace Slic3r {
namespace GUI {

namespace {

class MetalRenderDevice final : public RenderDevice
{
public:
    MetalRenderDevice()
    {
        m_info.backend = RendererBackend::Metal;
        m_info.renderer_name = renderer_backend_display_name(RendererBackend::Metal);

        m_device = MTLCreateSystemDefaultDevice();
        if (m_device == nil) {
            m_info.device_name = "Unavailable";
            m_info.available = false;
            return;
        }

        m_queue = [m_device newCommandQueue];
        m_info.device_name = [[m_device name] UTF8String];
        m_info.available = m_queue != nil;
    }

    const Info& info() const override { return m_info; }
    void* native_device_handle() const override { return (__bridge void*)m_device; }
    void* native_command_queue_handle() const override { return (__bridge void*)m_queue; }

private:
    Info m_info;
    id<MTLDevice> m_device { nil };
    id<MTLCommandQueue> m_queue { nil };
};

} // namespace

std::unique_ptr<RenderDevice> create_metal_render_device()
{
    return std::make_unique<MetalRenderDevice>();
}

} // namespace GUI
} // namespace Slic3r
