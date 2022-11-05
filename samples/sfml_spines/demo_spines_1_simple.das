require daslib/media
require sfml
require sfml_spine
require dasbox_sfml
require sfml_boost2

var spine: SpineWrapper?

[export]
def initialize
    set_window_title("sfml")
    spine = new SpineWrapper("spineboy-pro.skel", "spineboy-pma.atlas")
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
        clear(rt, Color(0u,255u,0u,255u))
        rt |> draw(spine, RenderStates_Default())