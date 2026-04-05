#ifndef slic3r_RenderDevice_hpp_
#define slic3r_RenderDevice_hpp_

#include <memory>
#include <string>

#include "RenderBackend.hpp"

namespace Slic3r {
namespace GUI {

class RenderDevice
{
public:
    struct Info
    {
        RendererBackend backend { RendererBackend::OpenGL };
        std::string renderer_name;
        std::string device_name;
        bool available { false };
    };

    virtual ~RenderDevice() = default;

    virtual const Info& info() const = 0;
    virtual void* native_device_handle() const = 0;
    virtual void* native_command_queue_handle() const = 0;

    static std::unique_ptr<RenderDevice> create(RendererBackend backend);
};

} // namespace GUI
} // namespace Slic3r

#endif // slic3r_RenderDevice_hpp_
