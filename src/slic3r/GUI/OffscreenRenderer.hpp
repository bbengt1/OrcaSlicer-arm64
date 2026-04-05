#ifndef slic3r_OffscreenRenderer_hpp_
#define slic3r_OffscreenRenderer_hpp_

#include "RenderContext.hpp"

namespace Slic3r {
namespace GUI {

class OffscreenRenderer
{
public:
    virtual ~OffscreenRenderer() = default;
    virtual bool render(const RenderContext& context) = 0;
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_OffscreenRenderer_hpp_
