Resolution = doublenickel.enum.define(
  'Resolution', 
  {
    Native = 0,
    Upscaled = 1
  }
)

Shader = doublenickel.enum.define(
  'Shader',
  {
    Sample = 0,
    Shape = 1,
    Sdf = 2,
    SdfNormal = 3,
    Solid = 5,
    Sprite = 6,
    Text = 7,
    Blit = 9,
  }
)

Font = doublenickel.enum.define(
  'Font',
  {
    Tiny5 = 0,
  }
)


RenderTarget = doublenickel.enum.define(
  'RenderTarget',
  {
    Native = 0,
    Upscaled = 1,
  }
)

Buffer = doublenickel.enum.define(
  'Buffer',
  {
    Lights = 0,
  }
)


local App = doublenickel.define_app()

function App:init()
  self.native_resolution = doublenickel.vec2(320, 180)
  self.output_resolution = doublenickel.vec2(1024, 576)
end

function App:on_init_game()
  local dn_config = AppConfig:new({
    target_fps = 144,
    window = WindowConfig:new({
      title = 'SDF Clock',
      native_resolution = Vector2:new(320, 180),
      flags = doublenickel.enum.bitwise_or(
        doublenickel.enums.WindowFlags.Windowed,
        doublenickel.enums.WindowFlags.Border
      ),
      icon = doublenickel.ffi.dn_paths_resolve_format('dn_image', 'logo/icon.png'):to_interned(),
    }),
    audio = AudioConfig:new({
      dirs = {
        doublenickel.ffi.dn_paths_resolve('audio'):to_interned()
      },
    }),
    font = FontConfig:new({
      fonts = {
        {
          id = Font.Tiny5,
          file_path = doublenickel.ffi.dn_paths_resolve_format('font', 'Tiny5-Regular.ttf'):to_interned(),
          sizes = { 16, 24, 32 },
          imgui = false
        },
      }
    }),
  gpu = GpuConfig:new({
      shader_path = doublenickel.ffi.dn_paths_resolve('shaders'):to_interned(),
      search_paths = {
          doublenickel.ffi.dn_paths_resolve('shader_includes'):to_interned()
      },
      shaders = {
        {
          name = Shader.Sample,
          kind = GpuShaderKind.Graphics,
          vertex_shader = doublenickel.ffi.dn_paths_resolve_format('shader', 'shader.vertex'):to_interned(),
          fragment_shader = doublenickel.ffi.dn_paths_resolve_format('shader', 'shader.fragment'):to_interned(),
        }
      },
      render_targets = {
        {
          name = RenderTarget.Native,
          size = self.native_resolution,
        },
        {
          name = RenderTarget.Upscaled,
          size = self.output_resolution,
        }
      }
    }),
    steam = SteamConfig:new({
      app_id = 480
    })
  })

  doublenickel.ffi.dn_app_configure(dn_config)

  doublenickel.asset.register_cast(RenderTarget, 'dn_gpu_render_target_t')
  doublenickel.asset.register_cast(Shader, 'dn_gpu_shader_t')

  -- doublenickel.gpu.build(doublenickel.module.read_from_named_path('gpu_info'))

  self.sdf_renderer = ffi.new('dn_sdf_renderer_t [1]');
  self.sdf_renderer = doublenickel.ffi.dn_sdf_renderer_create(1024 * 1024)

  self.command_buffer = doublenickel.ffi.dn_gpu_command_buffer_create(GpuCommandBufferDescriptor:new({
    max_commands = 1024
  }))

  self.render_pass = GpuRenderPass:new({
    color = {
      attachment = RenderTarget.Native,
      load = GpuLoadOp.Clear
    }
  })
end

function App:on_start_game()
  doublenickel.editor.configure(EditorConfig:new({
    grid_enabled = false,
    grid_size = 12,
    hide_dialogue_editor = true,
    game_views = {
      GameView:new(
        'Native View',
        RenderTarget.Native,
        doublenickel.enums.GameViewSize.ExactSize, self.native_resolution,
        doublenickel.enums.GameViewPriority.Main),
      GameView:new(
        'Upscaled View',
        RenderTarget.Upscaled,
        doublenickel.enums.GameViewSize.ExactSize, self.output_resolution,
        doublenickel.enums.GameViewPriority.Standard)
    },
    scene = 'sdf_clock',
    layout = 'sdf_clock',
    render_pass = self.render_pass,
    command_buffer = self.command_buffer
  }))
end

function App:on_scene_rendered()
  doublenickel.ffi.dn_gpu_begin_render_pass(self.command_buffer, self.render_pass)
  doublenickel.ffi.dn_gpu_set_world_space(self.command_buffer, true)
  doublenickel.ffi.dn_gpu_set_camera(self.command_buffer, doublenickel.editor.find('EditorCamera').offset:to_ctype())
  doublenickel.ffi.dn_sdf_renderer_draw(self.sdf_renderer, self.command_buffer)
  doublenickel.ffi.dn_gpu_end_render_pass(self.command_buffer)
  doublenickel.ffi.dn_gpu_command_buffer_submit(self.command_buffer)

  doublenickel.ffi.dn_gpu_render_target_blit(
    doublenickel.asset.find(RenderTarget.Native),
    doublenickel.asset.find(RenderTarget.Upscaled)
  )
end

function App:on_swapchain_ready()
  imgui.Imgui_Impl_glfw_opengl3:Render()
  -- doublenickel.ffi.render_imgui()
end

