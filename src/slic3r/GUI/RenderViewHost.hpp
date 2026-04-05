#ifndef slic3r_RenderViewHost_hpp_
#define slic3r_RenderViewHost_hpp_

#include <functional>
#include <memory>
#include <string>

#include <wx/panel.h>

#include "RenderBackend.hpp"
#include "RenderContext.hpp"

namespace Slic3r {
namespace GUI {

class RenderViewHost : public wxPanel
{
public:
    using ContextCallback = std::function<void(const RenderContext&)>;

    RenderViewHost(wxWindow* parent, RendererBackend backend, const wxString& name = "RenderViewHost");
    ~RenderViewHost() override;

    RendererBackend backend() const { return m_backend; }
    std::string backend_name() const { return renderer_backend_display_name(m_backend); }

    void set_frame_callback(ContextCallback callback) { m_frame_callback = std::move(callback); }
    void set_resize_callback(ContextCallback callback) { m_resize_callback = std::move(callback); }

    virtual RenderContext current_context() const;
    virtual bool is_ready() const = 0;
    virtual void request_redraw() = 0;

    static std::unique_ptr<RenderViewHost> create(wxWindow* parent, RendererBackend backend);

protected:
    RendererBackend m_backend;
    ContextCallback m_frame_callback;
    ContextCallback m_resize_callback;

    void notify_frame_presented(const RenderContext& context) const;
    void notify_resized(const RenderContext& context) const;
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_RenderViewHost_hpp_
