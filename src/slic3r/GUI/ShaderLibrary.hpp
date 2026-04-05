#ifndef slic3r_ShaderLibrary_hpp_
#define slic3r_ShaderLibrary_hpp_

#include <memory>
#include <string>

#include "RenderBackend.hpp"

namespace Slic3r {
namespace GUI {

class RenderDevice;

class ShaderLibrary
{
public:
    struct PipelineKey
    {
        std::string shader_name;
        bool textured { false };

        bool operator<(const PipelineKey& rhs) const
        {
            if (shader_name != rhs.shader_name)
                return shader_name < rhs.shader_name;
            return textured < rhs.textured;
        }
    };

    struct PipelineHandle
    {
        void* native_handle { nullptr };

        bool valid() const { return native_handle != nullptr; }
    };

    virtual ~ShaderLibrary() = default;

    virtual RendererBackend backend() const = 0;
    virtual bool is_ready() const = 0;
    virtual PipelineHandle pipeline_for(const PipelineKey& key, std::string* error_message = nullptr) = 0;

    static std::unique_ptr<ShaderLibrary> create(RenderDevice& device);
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_ShaderLibrary_hpp_
