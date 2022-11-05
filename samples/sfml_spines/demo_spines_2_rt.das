require daslib/media
require sfml
require sfml_spine
require dasbox_sfml
require sfml_boost2

var spine: SpineWrapper?

[export]
def initialize
    set_window_title("sfml")
    spine = new SpineWrapper("spineboy-pro.skel",  "spineboy-pma.atlas")
    spine |> set_position(320.0, 590.0)
    spine |> set_animation(0, "walk", true)

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()
    spine |> update(dt)

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
                //draw rt
                text_out(600, 200, "RT: simple", 0xFFFF0000)
                interface(sprite) <| $(var tr: Transformable)
                    tr |> move (300.0, 600.0)
                    tr |> scale(1.0, -1.0)
                rt |> draw(sprite, RenderStates_Default())
                //draw rt + blend state
                text_out(900, 200, "RT: satsub", 0xFF0000FF)
                interface(sprite) <| $(var tr: Transformable)
                    tr |> move (300.0, 0.0)
                using(Factor One, Factor OneMinusSrcAlpha, Equation Add) <| $(var blendMode: BlendMode#)
                    using(blendMode) <| $(var renderState: RenderStates#)
                        rt |> draw(sprite, renderState)
                            
