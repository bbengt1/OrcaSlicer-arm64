#ifndef slic3r_MetalRenderViewHost_hpp_
#define slic3r_MetalRenderViewHost_hpp_

#include <memory>

#include "RenderViewHost.hpp"

namespace Slic3r {
namespace GUI {

class MetalRenderViewHost final : public RenderViewHost
{
public:
    explicit MetalRenderViewHost(wxWindow* parent);
    ~MetalRenderViewHost() override;

    RenderContext current_context() const override;
    bool is_ready() const override;
    void request_redraw() override;

private:
    class Impl;
    std::unique_ptr<Impl> m_impl;

    void on_size(wxSizeEvent& event);
    void on_paint(wxPaintEvent& event);
    void on_erase_background(wxEraseEvent&) {}
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_MetalRenderViewHost_hpp_
