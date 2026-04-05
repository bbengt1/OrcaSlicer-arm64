#include "MetalRenderViewHost.hpp"

#include "RenderDevice.hpp"
#include "RenderTexture.hpp"
#include "SceneRenderer.hpp"
#include "ShaderLibrary.hpp"

#include <wx/dcclient.h>
#include <wx/window.h>

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

namespace Slic3r {
namespace GUI {

class MetalRenderViewHost::Impl
{
public:
    std::unique_ptr<RenderDevice> render_device;
    std::unique_ptr<ShaderLibrary> shader_library;
    std::unique_ptr<SceneRenderer> scene_renderer;
    std::unique_ptr<RenderTexture> debug_texture;
    id<MTLDevice> device { nil };
    id<MTLCommandQueue> command_queue { nil };
    CAMetalLayer* layer { nil };
    std::string device_name;
    std::string last_error;
    std::uint64_t frame_index { 0 };
    bool ready { false };

    bool initialize(wxWindow* host)
    {
        render_device = RenderDevice::create(RendererBackend::Metal);
        if (render_device == nullptr || !render_device->info().available)
            return false;

        device = (__bridge id<MTLDevice>)render_device->native_device_handle();
        command_queue = (__bridge id<MTLCommandQueue>)render_device->native_command_queue_handle();
        if (command_queue == nil)
            return false;

        shader_library = ShaderLibrary::create(*render_device);
        if (shader_library == nullptr || !shader_library->is_ready()) {
            last_error = "Metal shader library initialization failed.";
            return false;
        }

        scene_renderer = SceneRenderer::create(*render_device, *shader_library);
        if (scene_renderer == nullptr || !scene_renderer->is_ready()) {
            last_error = "Metal scene renderer initialization failed.";
            return false;
        }

        NSView* native_view = (NSView*)host->GetHandle();
        if (native_view == nil)
            return false;

        [native_view setWantsLayer:YES];
        layer = [CAMetalLayer layer];
        layer.device = device;
        layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        layer.framebufferOnly = YES;
        CGFloat scale = 1.0;
        if (native_view.window != nil) {
            scale = native_view.window.backingScaleFactor;
            if (native_view.window.screen != nil)
                scale = native_view.window.screen.backingScaleFactor;
        }
        layer.contentsScale = scale;
        native_view.layer = layer;

        const std::vector<std::uint8_t> debug_pixels = {
            255, 80, 48, 255,   255, 196, 0, 255,
            32, 192, 160, 255,  32, 96, 255, 255
        };
        debug_texture = create_render_texture(RendererBackend::Metal, 2, 2, debug_pixels);

        device_name = render_device->info().device_name;
        ready = true;
        resize(host->GetClientSize(), host->GetContentScaleFactor());
        return true;
    }

    void resize(const wxSize& size, double scale_factor)
    {
        if (!ready || layer == nil)
            return;

        const CGFloat scale = scale_factor > 0.0 ? scale_factor : 1.0;
        layer.contentsScale = scale;
        layer.drawableSize = CGSizeMake(size.GetWidth() * scale, size.GetHeight() * scale);
        layer.frame = CGRectMake(0.0, 0.0, size.GetWidth(), size.GetHeight());
    }

    void render()
    {
        if (!ready || layer == nil)
            return;

        @autoreleasepool {
            id<CAMetalDrawable> drawable = [layer nextDrawable];
            if (drawable == nil)
                return;

            MTLRenderPassDescriptor* descriptor = [MTLRenderPassDescriptor renderPassDescriptor];
            descriptor.colorAttachments[0].texture = drawable.texture;
            descriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
            descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
            descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.12, 0.13, 0.16, 1.0);

            id<MTLCommandBuffer> command_buffer = [command_queue commandBuffer];
            RenderContext context;
            context.drawable_width = static_cast<int>(layer.drawableSize.width);
            context.drawable_height = static_cast<int>(layer.drawableSize.height);
            context.scale_factor = static_cast<float>(layer.contentsScale);
            context.frame_index = frame_index;
            context.native_command_buffer = (__bridge void*)command_buffer;
            context.native_render_pass_descriptor = (__bridge void*)descriptor;
            context.native_drawable = (__bridge void*)drawable;
            context.valid = true;

            if (scene_renderer != nullptr)
                scene_renderer->render(context);

            [command_buffer presentDrawable:drawable];
            [command_buffer commit];
            ++frame_index;
        }
    }
};

MetalRenderViewHost::MetalRenderViewHost(wxWindow* parent)
    : RenderViewHost(parent, RendererBackend::Metal, "MetalRenderViewHost")
    , m_impl(std::make_unique<Impl>())
{
    SetBackgroundStyle(wxBG_STYLE_PAINT);
    Bind(wxEVT_SIZE, &MetalRenderViewHost::on_size, this);
    Bind(wxEVT_PAINT, &MetalRenderViewHost::on_paint, this);
    Bind(wxEVT_ERASE_BACKGROUND, &MetalRenderViewHost::on_erase_background, this);
    m_impl->initialize(this);
    notify_resized(current_context());
}

MetalRenderViewHost::~MetalRenderViewHost() = default;

RenderContext MetalRenderViewHost::current_context() const
{
    RenderContext context = RenderViewHost::current_context();
    context.frame_index = m_impl ? m_impl->frame_index : 0;
    context.valid = m_impl && m_impl->ready && context.valid;
    return context;
}

bool MetalRenderViewHost::is_ready() const
{
    return m_impl && m_impl->ready;
}

void MetalRenderViewHost::request_redraw()
{
    Refresh(false);
    Update();
}

void MetalRenderViewHost::on_size(wxSizeEvent& event)
{
    if (m_impl)
        m_impl->resize(GetClientSize(), GetContentScaleFactor());
    notify_resized(current_context());
    request_redraw();
    event.Skip();
}

void MetalRenderViewHost::on_paint(wxPaintEvent&)
{
    wxPaintDC dc(this);
    if (!m_impl || !m_impl->ready) {
        dc.SetBackground(*wxBLACK_BRUSH);
        dc.Clear();
        dc.SetTextForeground(*wxWHITE);
        const wxString error_message = m_impl && !m_impl->last_error.empty() ? wxString::FromUTF8(m_impl->last_error) : "Metal device unavailable.";
        dc.DrawText(error_message, wxPoint(12, 12));
        return;
    }

    m_impl->render();
    notify_frame_presented(current_context());
    dc.SetTextForeground(*wxWHITE);
    dc.DrawText("Experimental Metal host: " + wxString::FromUTF8(m_impl->device_name), wxPoint(12, 12));
}

} // namespace GUI
} // namespace Slic3r
