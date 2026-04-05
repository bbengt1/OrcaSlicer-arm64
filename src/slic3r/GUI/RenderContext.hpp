#ifndef slic3r_RenderContext_hpp_
#define slic3r_RenderContext_hpp_

#include <cstdint>

namespace Slic3r {
namespace GUI {

struct RenderContext
{
    int drawable_width { 0 };
    int drawable_height { 0 };
    float scale_factor { 1.0f };
    std::uint64_t frame_index { 0 };
    bool valid { false };
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_RenderContext_hpp_
