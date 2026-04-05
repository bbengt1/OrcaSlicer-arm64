#include "ShaderLibrary.hpp"

#include <map>

#include "RenderBuffer.hpp"
#include "RenderDevice.hpp"
#include "RenderTexture.hpp"

#import <Metal/Metal.h>

namespace Slic3r {
namespace GUI {

namespace {

NSString* metal_shader_source()
{
    return @"#include <metal_stdlib>\n"
           "using namespace metal;\n"
           "struct VertexIn {\n"
           "    float2 position [[attribute(0)]];\n"
           "    float4 color [[attribute(1)]];\n"
           "};\n"
           "struct VertexOut {\n"
           "    float4 position [[position]];\n"
           "    float4 color;\n"
           "};\n"
           "vertex VertexOut flat_vertex(VertexIn in [[stage_in]]) {\n"
           "    VertexOut out;\n"
           "    out.position = float4(in.position, 0.0, 1.0);\n"
           "    out.color = in.color;\n"
           "    return out;\n"
           "}\n"
           "fragment float4 flat_fragment(VertexOut in [[stage_in]]) {\n"
           "    return in.color;\n"
           "}\n";
}

class MetalShaderLibrary final : public ShaderLibrary
{
public:
    explicit MetalShaderLibrary(RenderDevice& device)
    {
        m_device = (__bridge id<MTLDevice>)device.native_device_handle();
        if (m_device == nil)
            return;

        NSError* error = nil;
        m_library = [m_device newLibraryWithSource:metal_shader_source() options:nil error:&error];
        if (m_library == nil && error != nil)
            m_last_error = [[error localizedDescription] UTF8String];
    }

    RendererBackend backend() const override { return RendererBackend::Metal; }
    bool is_ready() const override { return m_device != nil && m_library != nil; }

    PipelineHandle pipeline_for(const PipelineKey& key, std::string* error_message = nullptr) override
    {
        auto found = m_pipelines.find(key);
        if (found != m_pipelines.end())
            return { (__bridge void*)found->second };

        if (!is_ready()) {
            if (error_message != nullptr)
                *error_message = m_last_error.empty() ? "Metal shader library is not initialized." : m_last_error;
            return {};
        }

        if (key.shader_name != "flat") {
            if (error_message != nullptr)
                *error_message = "Unsupported Metal pipeline key: " + key.shader_name;
            return {};
        }

        id<MTLFunction> vertex_function = [m_library newFunctionWithName:@"flat_vertex"];
        id<MTLFunction> fragment_function = [m_library newFunctionWithName:@"flat_fragment"];
        if (vertex_function == nil || fragment_function == nil) {
            if (error_message != nullptr)
                *error_message = "Required Metal shader functions are missing.";
            return {};
        }

        MTLRenderPipelineDescriptor* descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.vertexFunction = vertex_function;
        descriptor.fragmentFunction = fragment_function;
        descriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;

        MTLVertexDescriptor* vertex_descriptor = [[MTLVertexDescriptor alloc] init];
        vertex_descriptor.attributes[0].format = MTLVertexFormatFloat2;
        vertex_descriptor.attributes[0].offset = 0;
        vertex_descriptor.attributes[0].bufferIndex = 0;
        vertex_descriptor.attributes[1].format = MTLVertexFormatFloat4;
        vertex_descriptor.attributes[1].offset = sizeof(float) * 2;
        vertex_descriptor.attributes[1].bufferIndex = 0;
        vertex_descriptor.layouts[0].stride = sizeof(float) * 6;
        vertex_descriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
        descriptor.vertexDescriptor = vertex_descriptor;

        NSError* error = nil;
        id<MTLRenderPipelineState> pipeline = [m_device newRenderPipelineStateWithDescriptor:descriptor error:&error];
        if (pipeline == nil) {
            if (error != nil)
                m_last_error = [[error localizedDescription] UTF8String];
            if (error_message != nullptr)
                *error_message = m_last_error.empty() ? "Failed to create Metal render pipeline." : m_last_error;
            return {};
        }

        m_pipelines.emplace(key, pipeline);
        return { (__bridge void*)pipeline };
    }

private:
    id<MTLDevice> m_device { nil };
    id<MTLLibrary> m_library { nil };
    std::map<PipelineKey, id<MTLRenderPipelineState>> m_pipelines;
    std::string m_last_error;
};

class MetalRenderBuffer final : public RenderBuffer
{
public:
    explicit MetalRenderBuffer(const Descriptor& descriptor, id<MTLDevice> device)
        : m_descriptor(descriptor)
        , m_device(device)
    {
    }

    const Descriptor& descriptor() const override { return m_descriptor; }

    bool upload(const void* data, std::size_t size_bytes) override
    {
        if (m_device == nil || data == nullptr || size_bytes == 0)
            return false;

        m_buffer = [m_device newBufferWithBytes:data length:size_bytes options:MTLResourceStorageModeShared];
        return m_buffer != nil;
    }

    void* native_handle() const override { return (__bridge void*)m_buffer; }

private:
    Descriptor m_descriptor;
    id<MTLDevice> m_device { nil };
    id<MTLBuffer> m_buffer { nil };
};

class MetalRenderTexture final : public RenderTexture
{
public:
    explicit MetalRenderTexture(const Descriptor& descriptor, id<MTLDevice> device)
        : m_descriptor(descriptor)
        , m_device(device)
    {
    }

    const Descriptor& descriptor() const override { return m_descriptor; }

    bool upload_rgba8(const void* data, std::size_t size_bytes) override
    {
        if (m_device == nil || data == nullptr || size_bytes == 0 || m_descriptor.width <= 0 || m_descriptor.height <= 0)
            return false;

        const std::size_t expected_size = static_cast<std::size_t>(m_descriptor.width) * static_cast<std::size_t>(m_descriptor.height) * 4;
        if (size_bytes < expected_size)
            return false;

        MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                               width:m_descriptor.width
                                                                                              height:m_descriptor.height
                                                                                           mipmapped:NO];
        descriptor.usage = MTLTextureUsageShaderRead;
        m_texture = [m_device newTextureWithDescriptor:descriptor];
        if (m_texture == nil)
            return false;

        MTLRegion region = MTLRegionMake2D(0, 0, m_descriptor.width, m_descriptor.height);
        [m_texture replaceRegion:region mipmapLevel:0 withBytes:data bytesPerRow:m_descriptor.width * 4];
        return true;
    }

    void* native_handle() const override { return (__bridge void*)m_texture; }

private:
    Descriptor m_descriptor;
    id<MTLDevice> m_device { nil };
    id<MTLTexture> m_texture { nil };
};

} // namespace

std::unique_ptr<ShaderLibrary> create_metal_shader_library(RenderDevice& device)
{
    return std::make_unique<MetalShaderLibrary>(device);
}

std::unique_ptr<RenderBuffer> create_metal_render_buffer(const RenderBuffer::Descriptor& descriptor)
{
    auto device = RenderDevice::create(RendererBackend::Metal);
    if (device == nullptr || !device->info().available)
        return nullptr;

    return std::make_unique<MetalRenderBuffer>(descriptor, (__bridge id<MTLDevice>)device->native_device_handle());
}

std::unique_ptr<RenderTexture> create_metal_render_texture(const RenderTexture::Descriptor& descriptor)
{
    auto device = RenderDevice::create(RendererBackend::Metal);
    if (device == nullptr || !device->info().available)
        return nullptr;

    return std::make_unique<MetalRenderTexture>(descriptor, (__bridge id<MTLDevice>)device->native_device_handle());
}

} // namespace GUI
} // namespace Slic3r
