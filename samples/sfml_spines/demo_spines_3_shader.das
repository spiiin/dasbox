require daslib/media
require sfml
require sfml_spine
require dasbox_sfml
require sfml_boost2

var spine: SpineWrapper?

var shaderTex : Shader?
var rsShader : RenderStates?
var time: float

var fragmentShader = (
"uniform sampler2D texture;
uniform float time;
uniform float waveX;
uniform float waveY;
uniform float distanceX;
uniform float distanceY;
uniform float turnCoeff;

float2 liquidTc(float2 p, float waveX, float waveY, float distanceX, float distanceY)
\{
	float speed = time;
	p.x = p.x+sin(p.y*waveX + speed)*distanceX*0.05;
	p.y = p.y+cos(p.x*waveY + speed)*distanceY*0.05;
	return p;
\}

void main()
\{
	vec2 tc = gl_TexCoord[0].xy;
	vec2 liquid_tc = liquidTc(tc, waveX, waveY, distanceX, distanceY);
	vec2 final_tc = mix(tc, liquid_tc, turnCoeff);
	vec4 pixel = texture2D(texture, final_tc);
	gl_FragColor = gl_Color * pixel;
\}")

[export]
def initialize
    set_window_title("sfml")

    spine = new SpineWrapper("spineboy-pro.skel",  "spineboy-pma.atlas")
    spine |> set_position(320.0, 590.0)
    spine |> set_animation(0, "walk", true)

    shaderTex = new Shader()
    shaderTex |> load_fragment_shader_from_string(fragmentShader)    
    shaderTex |> bind_current_texture_to_uniform("texture")
    shaderTex |> bind_uniform("time", 0.0)
    shaderTex |> bind_uniform("waveX", 5.0)
    shaderTex |> bind_uniform("waveY", 10.0)
    shaderTex |> bind_uniform("distanceX", 0.6)
    shaderTex |> bind_uniform("distanceY", 0.4)
    shaderTex |> bind_uniform("turnCoeff", 1.0)
    rsShader = makeRenderTarget(shaderTex, new BlendMode(Factor One, Factor OneMinusSrcAlpha, Equation Add))

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    spine |> update(dt)
    time += dt * 5.0
    shaderTex |> bind_uniform("time", time)

[export]
def draw
    withRenderTarget <| $(var rt: RenderTarget&)
        rt |> clear(Color(0u,255u,0u,255u))
        //simple draw
        text_out(300, 200, "Simple", 0xFFFF00FF)
        rt |> draw(spine, RenderStates_Default())
        
        using() <| $(var rtTex: RenderTexture#)
            rtTex |> create(800u, 600u, false)
            rtTex |> clear(Color(0u,0u,0u,0u))
            rtTex |> draw(spine, RenderStates_Default())
            using(rtTex |> getTexture()) <| $(var sprite: Sprite#)
                //draw with shader
                text_out(600, 200, "Liquid shader", 0xFF0000FF)
                interface(sprite) <| $(var tr: Transformable)
                    tr |> move (300.0, 600.0)
                    tr |> scale(1.0, -1.0)
                rt |> draw(sprite, *rsShader)
                            
