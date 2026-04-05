#include "MetalRenderViewHost.hpp"

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
    id<MTLDevice> device { nil };
    id<MTLCommandQueue> command_queue { nil };
    CAMetalLayer* layer { nil };
    std::string device_name;
    std::uint64_t frame_index { 0 };
    bool ready { false };

    bool initialize(wxWindow* host)
    {
        device = MTLCreateSystemDefaultDevice();
        if (device == nil)
            return false;

        command_queue = [device newCommandQueue];
        if (command_queue == nil)
            return false;

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

        device_name = [[device name] UTF8String];
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
            id<MTLRenderCommandEncoder> encoder = [command_buffer renderCommandEncoderWithDescriptor:descriptor];
            [encoder endEncoding];
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
        dc.DrawText("Metal device unavailable.", wxPoint(12, 12));
        return;
    }

    m_impl->render();
    dc.SetTextForeground(*wxWHITE);
    dc.DrawText("Experimental Metal host: " + wxString::FromUTF8(m_impl->device_name), wxPoint(12, 12));
}

} // namespace GUI
} // namespace Slic3r
