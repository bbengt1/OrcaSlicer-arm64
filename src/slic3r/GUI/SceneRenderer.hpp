#ifndef slic3r_SceneRenderer_hpp_
#define slic3r_SceneRenderer_hpp_

#include "RenderContext.hpp"

namespace Slic3r {
namespace GUI {

class SceneRenderer
{
public:
    virtual ~SceneRenderer() = default;
    virtual void render(const RenderContext& context) = 0;
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_SceneRenderer_hpp_
