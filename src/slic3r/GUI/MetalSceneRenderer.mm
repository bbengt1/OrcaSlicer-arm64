#include "SceneRenderer.hpp"

#include <vector>

#include "RenderBuffer.hpp"
#include "RenderDevice.hpp"
#include "ShaderLibrary.hpp"

#import <Metal/Metal.h>

namespace Slic3r {
namespace GUI {

namespace {

class MetalSceneRenderer final : public SceneRenderer
{
public:
    MetalSceneRenderer(RenderDevice& device, ShaderLibrary& shader_library)
        : m_device((__bridge id<MTLDevice>)device.native_device_handle())
        , m_shader_library(shader_library)
    {
        const std::vector<float> triangle = {
            0.0f,  0.72f, 0.96f, 0.45f, 0.20f, 1.0f,
           -0.72f, -0.60f, 0.20f, 0.72f, 0.98f, 1.0f,
            0.72f, -0.60f, 0.98f, 0.86f, 0.28f, 1.0f,
        };
        m_vertex_buffer = create_render_buffer<float>(RendererBackend::Metal, triangle);
        m_ready = m_device != nil && m_vertex_buffer != nullptr && m_vertex_buffer->valid() && m_shader_library.is_ready();
    }

    bool is_ready() const override { return m_ready; }

    void render(const RenderContext& context) override
    {
        if (!m_ready || !context.valid)
            return;

        id<MTLCommandBuffer> command_buffer = (__bridge id<MTLCommandBuffer>)context.native_command_buffer;
        MTLRenderPassDescriptor* descriptor = (__bridge MTLRenderPassDescriptor*)context.native_render_pass_descriptor;
        if (command_buffer == nil || descriptor == nil)
            return;

        std::string error_message;
        ShaderLibrary::PipelineHandle pipeline_handle = m_shader_library.pipeline_for({ "flat", false }, &error_message);
        if (!pipeline_handle.valid())
            return;

        id<MTLRenderPipelineState> pipeline = (__bridge id<MTLRenderPipelineState>)pipeline_handle.native_handle;
        id<MTLBuffer> vertex_buffer = (__bridge id<MTLBuffer>)m_vertex_buffer->native_handle();
        if (pipeline == nil || vertex_buffer == nil)
            return;

        id<MTLRenderCommandEncoder> encoder = [command_buffer renderCommandEncoderWithDescriptor:descriptor];
        if (encoder == nil)
            return;

        [encoder setRenderPipelineState:pipeline];
        [encoder setVertexBuffer:vertex_buffer offset:0 atIndex:0];
        [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        [encoder endEncoding];
    }

private:
    id<MTLDevice> m_device { nil };
    ShaderLibrary& m_shader_library;
    std::unique_ptr<RenderBuffer> m_vertex_buffer;
    bool m_ready { false };
};

} // namespace

std::unique_ptr<SceneRenderer> create_metal_scene_renderer(RenderDevice& device, ShaderLibrary& shader_library)
{
    return std::make_unique<MetalSceneRenderer>(device, shader_library);
}

} // namespace GUI
} // namespace Slic3r
