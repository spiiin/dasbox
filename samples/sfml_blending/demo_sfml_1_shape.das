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

[export]
def draw
    withRenderTarget <| $(var rt: RenderTarget&)
        clear(rt, Color(0u,255u,0u,255u))
        using(50.0f,0x1eul) <| $(var shape: CircleShape#)
            interface(shape) <| $(var tr: Transformable)
                tr |> move(20.,30.)
            shape |> setFillColor(Color(150u,50u,250u,255u))
            shape |> setOutlineThickness(10.f)
            shape |> setOutlineColor(Color(250u,150u,100u,255u))
            rt |> draw(shape, RenderStates_Default())
