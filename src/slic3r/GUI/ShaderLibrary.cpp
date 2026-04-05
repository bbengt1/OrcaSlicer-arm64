#include "ShaderLibrary.hpp"

#include "RenderDevice.hpp"

namespace Slic3r {
namespace GUI {

#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
std::unique_ptr<ShaderLibrary> create_metal_shader_library(RenderDevice& device);
#endif

namespace {

class NullShaderLibrary final : public ShaderLibrary
{
public:
    explicit NullShaderLibrary(RendererBackend backend)
        : m_backend(backend)
    {
    }

    RendererBackend backend() const override { return m_backend; }
    bool is_ready() const override { return false; }

    PipelineHandle pipeline_for(const PipelineKey&, std::string* error_message = nullptr) override
    {
        if (error_message != nullptr)
            *error_message = "Renderer backend does not provide a shader library.";
        return {};
    }

private:
    RendererBackend m_backend;
};

} // namespace

std::unique_ptr<ShaderLibrary> ShaderLibrary::create(RenderDevice& device)
{
#if defined(__APPLE__) && defined(SLIC3R_EXPERIMENTAL_METAL)
    if (device.info().backend == RendererBackend::Metal)
        return create_metal_shader_library(device);
#endif

    return std::make_unique<NullShaderLibrary>(device.info().backend);
}

} // namespace GUI
} // namespace Slic3r
