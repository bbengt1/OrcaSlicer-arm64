#include "RenderViewHost.hpp"

#include <wx/dcclient.h>

#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
#include "MetalRenderViewHost.hpp"
#endif

namespace Slic3r {
namespace GUI {

namespace {

class UnsupportedRenderViewHost final : public RenderViewHost
{
public:
    UnsupportedRenderViewHost(wxWindow* parent, RendererBackend backend)
        : RenderViewHost(parent, backend, "UnsupportedRenderViewHost")
    {
        Bind(wxEVT_PAINT, &UnsupportedRenderViewHost::on_paint, this);
    }

    bool is_ready() const override { return false; }

    void request_redraw() override
    {
        Refresh();
    }

private:
    void on_paint(wxPaintEvent&)
    {
        wxPaintDC dc(this);
        dc.SetBackground(*wxBLACK_BRUSH);
        dc.Clear();
        dc.SetTextForeground(*wxWHITE);
        dc.DrawText("Experimental renderer unavailable on this build.", wxPoint(12, 12));
    }
};

} // namespace

RenderViewHost::RenderViewHost(wxWindow* parent, RendererBackend backend, const wxString& name)
    : wxPanel(parent, wxID_ANY, wxDefaultPosition, wxDefaultSize, wxBORDER_NONE, name)
    , m_backend(backend)
{
}

RenderViewHost::~RenderViewHost() = default;

RenderContext RenderViewHost::current_context() const
{
    RenderContext context;
    context.drawable_width = GetClientSize().GetWidth();
    context.drawable_height = GetClientSize().GetHeight();
    context.scale_factor = static_cast<float>(GetContentScaleFactor());
    context.valid = context.drawable_width > 0 && context.drawable_height > 0;
    return context;
}

std::unique_ptr<RenderViewHost> RenderViewHost::create(wxWindow* parent, RendererBackend backend)
{
#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
    if (backend == RendererBackend::Metal)
        return std::make_unique<MetalRenderViewHost>(parent);
#endif

    return std::make_unique<UnsupportedRenderViewHost>(parent, backend);
}

} // namespace GUI
} // namespace Slic3r
