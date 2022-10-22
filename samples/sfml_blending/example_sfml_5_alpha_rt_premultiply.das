require daslib/media
require sfml
require sfml_boost2
require dasbox_sfml

var fragmentShaderTex = (
"uniform sampler2D texture;
void main()
\{
    gl_FragColor = texture2D(texture, gl_TexCoord[0].st);
\}")

var fragmentShaderPremultiply = (
"void main()
\{
    //gl_FragColor = gl_Color;  //for testing no premultiply
    gl_FragColor = vec4(gl_Color.rgb * gl_Color.a, gl_Color.a);
\}")

var rsPremultiplySatSub, rsSatSub : RenderStates?

[export]
def initialize
    set_window_title("sfml") 

    var shaderPremult = new Shader()
    shaderPremult |> load_fragment_shader_from_string(fragmentShaderPremultiply)

    var shaderTex = new Shader()
    shaderTex |> load_fragment_shader_from_string(fragmentShaderTex)    
    shaderTex |> bind_current_texture_to_uniform("texture")
    
    var blendModeSatSubSeparate = new BlendMode(Factor One, Factor OneMinusSrcAlpha, Equation Add, Factor OneMinusDstAlpha, Factor One, Equation Add)

    rsPremultiplySatSub = makeRenderTarget(shaderPremult, blendModeSatSubSeparate)
    rsSatSub = makeRenderTarget(shaderTex, blendModeSatSubSeparate)
[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

def drawCircles(var rt: RenderTarget&; rs: RenderStates& implicit)
    using(125.0f, 128ul) <| $(var shape: CircleShape#)
        shape |> setFillColor(Color(0u,255u,0u,128u))
        rt |> draw(shape, rs)
    using(125.0f, 128ul) <| $(var shape: CircleShape#)
        interface(shape) <| $(var tr: Transformable) { tr |> move(125.0f, 0.0f); }
        shape |> setFillColor(Color(255u,05u,0u,128u))
        rt |> draw(shape, rs)

def render_with_blend_and_premultiply(var rt: RenderTarget&)
    drawCircles(rt, *rsPremultiplySatSub)

def render_sprite_with_blend(var rt: RenderTarget&; var sprite: Sprite& implicit)
    rt |> draw(sprite, *rsSatSub)

[export]
def draw
    withRenderTarget <| $(var rt: RenderTarget&)
        rt |> clear(Color(255u,255u,255u,255u))

        //simple draw
        text_out(0, 0, "Simple", 0xFF000000)
        drawCircles(rt, RenderStates_Default())

        //render texture draw
        text_out(0, 300, "Texture: Premult", 0xFF000000)

        using() <| $(var rtTex: RenderTexture#)
            rtTex |> create(250u + 125u, 250u, false)
            rtTex |> clear(Color(0u, 0u, 0u, 0u))
            render_with_blend_and_premultiply(rtTex)
            using(rtTex |> getTexture()) <| $(var sprite: Sprite#)
                interface(sprite) <| $(var tr: Transformable)
                    tr |> move(0.0f, 300.0f)
                render_sprite_with_blend(rt, sprite)
