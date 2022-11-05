require daslib/media
require sfml
require sfml_spine
require dasbox_sfml
require sfml_boost2
require opengl/opengl_boost
require daslib/safe_addr

var spine, spineHole: SpineWrapper?
var POST_INIT_GL = false

var program : uint
var vao : uint
var vbo : uint
let GL_ONEU : uint = uint(1)

var [[in, location=0]] v_position : float2
var [[in, location=1]] v_color : float3
var [[inout]] f_color : float3
var [[out]] f_FragColor : float4

[vertex_program]
def vs_main
    f_color = v_color
    gl_Position = float4(v_position, 0.0, 1.0)

[fragment_program]
def fs_main
    f_FragColor = float4(f_color, 1.0)

[vertex_buffer]
struct VertexCol
    xy : float2
    rgb : float3

let vertices = [[VertexCol
    xy=float2(-0.8, 0.7), rgb=float3(1.0,1.0,0.0);
    xy=float2(-0.8,-0.8), rgb=float3(1.0,1.0,1.0);
    xy=float2( 0.1,-0.8), rgb=float3(1.0,1.0,1.0);

    xy=float2(-0.8, 0.7), rgb=float3(1.0,1.0,0.0);
    xy=float2( 0.1, 0.7), rgb=float3(1.0,1.0,1.0);
    xy=float2( 0.1,-0.8), rgb=float3(1.0,1.0,1.0)
]]

def create_gl_objects
    program = create_shader_program(@@vs_main,@@fs_main)
    // vao
    glGenVertexArrays(1, safe_addr(vao))
    glBindVertexArray(vao);
    // vbo
    glGenBuffers(1, safe_addr(vbo))
    glBindBuffer(GL_ARRAY_BUFFER, vbo)
    glBufferData(GL_ARRAY_BUFFER, vertices, GL_STATIC_DRAW)
    bind_vertex_buffer(null, type<VertexCol>)
    glBindVertexArray(0u)

[export]
def initialize
    set_window_title("sfml")
    spine = new SpineWrapper("spineboy-pro.skel",  "spineboy-pma.atlas")
    spine |> set_position(320.0, 590.0)
    spine |> set_animation(0, "walk", true)

    spineHole = new SpineWrapper("vine-pro.skel",  "vine-pma.atlas")
    spineHole |> set_premultiply_alpha(false)
    spineHole |> set_position(320.0, 640.0)
    spineHole |> set_animation(0, "grow", true)

[export]
def act(dt: float)
    if !POST_INIT_GL
        create_gl_objects()
        POST_INIT_GL = true

    if get_key(VK_ESCAPE)
        schedule_quit_game()
    spine |> update(dt)
    spineHole |> update(dt)

[export]
def draw
    withRenderTarget <| $(var rt: RenderTarget&)
        rt |> clear(Color(0u,255u,0u,0u))
        //draw base spine
        rt |> draw(spine, RenderStates_Default())

        //draw hole spine
        using(Factor Zero, Factor OneMinusSrcAlpha, Equation Add) <| $(var blendMode: BlendMode#)
            using(blendMode) <| $(var renderState: RenderStates#)
                rt |> draw(spineHole, renderState)

        //draw triangle, special render mode
        glBlendFuncSeparate(GL_SRC_ALPHA_SATURATE, GL_ONEU, GL_ONEU, GL_ONE_MINUS_SRC_ALPHA)
        glUseProgram(program)
        vs_main_bind_uniform(program)
        fs_main_bind_uniform(program)
        glBindVertexArray(vao)
        glDrawArrays(GL_TRIANGLES, 0, 6)
        glBindVertexArray(0u)
        glUseProgram(0u)
                            
