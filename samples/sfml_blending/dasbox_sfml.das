module dasbox_sfml
require daslib/media

[export]
def withRenderTarget(blk)
    unsafe
        invoke(blk, *get_render_target())