#include "SceneRenderer.hpp"

#include "RenderDevice.hpp"
#include "ShaderLibrary.hpp"

namespace Slic3r {
namespace GUI {

#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
std::unique_ptr<SceneRenderer> create_metal_scene_renderer(RenderDevice& device, ShaderLibrary& shader_library);
#endif

namespace {

class NullSceneRenderer final : public SceneRenderer
{
public:
    bool is_ready() const override { return false; }
    void render(const RenderContext&) override {}
};

} // namespace

std::unique_ptr<SceneRenderer> SceneRenderer::create(RenderDevice& device, ShaderLibrary& shader_library)
{
#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
    if (device.info().backend == RendererBackend::Metal)
        return create_metal_scene_renderer(device, shader_library);
#endif

    return std::make_unique<NullSceneRenderer>();
}

} // namespace GUI
} // namespace Slic3r
