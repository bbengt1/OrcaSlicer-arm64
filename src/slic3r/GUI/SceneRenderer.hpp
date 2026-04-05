#ifndef slic3r_SceneRenderer_hpp_
#define slic3r_SceneRenderer_hpp_

#include <memory>

#include "RenderContext.hpp"

namespace Slic3r {
namespace GUI {

class RenderDevice;
class ShaderLibrary;

class SceneRenderer
{
public:
    virtual ~SceneRenderer() = default;
    virtual bool is_ready() const = 0;
    virtual void render(const RenderContext& context) = 0;

    static std::unique_ptr<SceneRenderer> create(RenderDevice& device, ShaderLibrary& shader_library);
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_SceneRenderer_hpp_
