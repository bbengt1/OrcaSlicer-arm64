#ifndef slic3r_RenderBackend_hpp_
#define slic3r_RenderBackend_hpp_

#include <string>

namespace Slic3r {
namespace GUI {

enum class RendererBackend : unsigned char
{
    OpenGL,
    Metal
};

inline const char* renderer_backend_name(RendererBackend backend)
{
    switch (backend) {
    case RendererBackend::Metal:  return "metal";
    case RendererBackend::OpenGL: return "opengl";
    }

    return "opengl";
}

inline std::string renderer_backend_display_name(RendererBackend backend)
{
    switch (backend) {
    case RendererBackend::Metal:  return "Metal";
    case RendererBackend::OpenGL: return "OpenGL";
    }

    return "OpenGL";
}

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_RenderBackend_hpp_
