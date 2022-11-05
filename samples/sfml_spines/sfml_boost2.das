require daslib/media
require sfml
require sfml_spine

//shaders

def load_fragment_shader_from_string(var shader: Shader?; shaderText: string)
    using() <| $(var fs: das_string#)
        fs := shaderText
        *shader |> loadFromMemory(fs, Type Fragment)

def bind_current_texture_to_uniform(var shader: Shader?; texName: string)
    using() <| $(var curTex : CurrentTextureType#)
        using() <| $(var textureStr: das_string#)
            textureStr := texName
            *shader |> setParameter(textureStr, curTex)

def bind_uniform(var shader: Shader?; paramName: string; value)
    using() <| $(var dasParam: das_string#)
        dasParam := paramName
        *shader |> setParameter(dasParam, value)

//renderStates

def makeRenderTarget(shader: Shader?; blendMode: BlendMode?)
    return new RenderStates(*blendMode, Transform(), new Texture(), shader)

//spine
def draw(var rt: RenderTarget implicit; spine:SpineWrapper?; rs:RenderStates implicit)
    unsafe
        rt |> draw(reinterpret<Drawable&> *get_skeleton(spine), rs)
