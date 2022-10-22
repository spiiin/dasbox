require daslib/media
require sfml
require dasbox_sfml

[export]
def initialize
    set_window_title("sfml")

[export]
def act(dt: float)
    if get_key(VK_ESCAPE)
        schedule_quit_game()

def drawCircles(var rt: RenderTarget&)
    using(125.0f, 128ul) <| $(var shape: CircleShape#)
        shape |> setFillColor(Color(0u,255u,0u,128u))
        rt |> draw(shape, RenderStates_Default())
    using(125.0f, 128ul) <| $(var shape: CircleShape#)
        interface(shape) <| $(var tr: Transformable) { tr |> move(125.0f, 0.0f); }
        shape |> setFillColor(Color(255u,05u,0u,128u))
        rt |> draw(shape, RenderStates_Default())

[export]
def draw
    withRenderTarget <| $(var rt: RenderTarget&)
        rt |> clear(Color(255u,255u,255u,255u))

        //simple draw
        text_out(0, 0, "Simple", 0xFF000000)
        drawCircles(rt)

        //render texture draw
        text_out(0, 300, "Texture: Satsub", 0xFF000000)
        using() <| $(var rtTex: RenderTexture#)
            rtTex |> create(250u + 125u, 250u, false)
            rtTex |> clear(Color(0u, 0u, 0u, 0u))
            drawCircles(rtTex)
            using(rtTex |> getTexture()) <| $(var sprite: Sprite#)
                interface(sprite) <| $(var tr: Transformable)
                    tr |> move(0.0f, 300.0f)
                using(Factor One, Factor OneMinusSrcAlpha, Equation Add) <| $(var blendMode: BlendMode#)
                    using(blendMode) <| $(var renderState: RenderStates#)
                        rt |> draw(sprite, renderState)
