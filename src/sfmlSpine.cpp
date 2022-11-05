#include <daScript/daScript.h>
#include <daScript/ast/ast.h>
#include <daScript/simulate/interop.h>
#include <daScript/simulate/simulate_visit_op.h>
#include <daScript/simulate/aot_builtin_fio.h>

#include <SFML/Graphics.hpp>
#include <iostream>
#include <spine/Debug.h>
#include <spine/Log.h>
#include <spine-sfml.h>

using namespace das;
using namespace spine;

SkeletonData* readSkeletonBinaryData(const char* filename, Atlas* atlas, float scale) {
	SkeletonBinary binary(atlas);
	binary.setScale(scale);
	auto skeletonData = binary.readSkeletonDataFile(filename);
	if (!skeletonData) {
		printf("%s\n", binary.getError().buffer());
		exit(0);
	}
	return skeletonData;
}

struct SpineWrapper {
	SpineWrapper(const char* binaryName, const char* atlasName) {
		create_spine(binaryName, atlasName);
	}

	void create_spine(const char* binaryName, const char* atlasName) {
		SFMLTextureLoader textureLoader;
		auto atlas = new Atlas(atlasName, &textureLoader);
		skeletonData = readSkeletonBinaryData(binaryName, atlas, 0.5f);
		drawable = new SkeletonDrawable(skeletonData);
		drawable->setUsePremultipliedAlpha(true);

		Skeleton* skeleton = drawable->skeleton;
		skeleton->setToSetupPose();
		skeleton->updateWorldTransform();
	}

	~SpineWrapper() {
		delete skeletonData;
		delete drawable;
	}
	SkeletonDrawable* drawable = nullptr;
	SkeletonData* skeletonData = nullptr;
};

void set_position(SpineWrapper* spine, float x, float y) {
	spine->drawable->skeleton->setPosition(x, y);
}

void set_animation(SpineWrapper* spine, int trackNo, const char* animation, bool repeat) {
	spine->drawable->state->setAnimation(trackNo, animation, repeat);
}

void update(SpineWrapper* spine, float dt) {
	spine->drawable->update(dt);
}

SkeletonDrawable* get_skeleton(SpineWrapper* spine) {
	return spine->drawable;
}

void set_premultiply_alpha(SpineWrapper* spine, bool pma) {
	spine->drawable->setUsePremultipliedAlpha(pma);
}

struct sf_SpineWrapper_Annotation : ManagedStructureAnnotation<SpineWrapper> {
	sf_SpineWrapper_Annotation(ModuleLibrary& ml) : ManagedStructureAnnotation("SpineWrapper", ml, "SpineWrapper") {
	}
	virtual bool canNew() const override { return true; }
	void init() {
	}
};

MAKE_TYPE_FACTORY(SpineWrapper, SpineWrapper);
MAKE_TYPE_FACTORY(SkeletonDrawable, SkeletonDrawable);

class ModuleSfmlSpine : public Module
{
public:
    ModuleSfmlSpine() : Module("sfml_spine")
  {
    ModuleLibrary lib;
    lib.addModule(this);
    lib.addBuiltInModule();

	addAnnotation(make_smart<sf_SpineWrapper_Annotation>(lib));
	addAnnotation(make_smart<DummyTypeAnnotation>("SkeletonDrawable", "SkeletonDrawable", 1, 1));
	addCtorAndUsing<SpineWrapper, const char*, const char*>(*this, lib, "SpineWrapper", "SpineWrapper");
	addExtern<DAS_BIND_FUN(set_position)>(*this, lib, "set_position", SideEffects::worstDefault, "set_position");
	addExtern<DAS_BIND_FUN(set_animation)>(*this, lib, "set_animation", SideEffects::worstDefault, "set_animation");
	addExtern<DAS_BIND_FUN(update)>(*this, lib, "update", SideEffects::worstDefault, "update");
	addExtern<DAS_BIND_FUN(set_premultiply_alpha)>(*this, lib, "set_premultiply_alpha", SideEffects::worstDefault, "set_premultiply_alpha");
	addExtern<DAS_BIND_FUN(get_skeleton)>(*this, lib, "get_skeleton", SideEffects::worstDefault, "get_skeleton")->unsafeOperation = true;

    // its AOT ready
    //verifyAotReady();
  }

  virtual ModuleAotType aotRequire(TextWriter & tw) const override
  {
    //tw << "#include \"test_profile.h\"\n";
    return ModuleAotType::cpp;
  }
};

REGISTER_MODULE(ModuleSfmlSpine);
