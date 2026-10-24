# Stealth Drop Tanks — editable authoring kit

Original geometry asset 0.5.1, current surface detail and runtime 0.4.6.
This kit is for editing and conversion; install the separate public beta game package
to play. Nothing here is a prerequisite for that package.

## Contents

- exports/F22_StealthTank.blend: current detailed packed Blender scene, metres,
  authored normals/UVs, lights/cameras and preview floor at Z = -5 m.
- exports/*LOD0/1/2.glb: unchanged authored geometry with current embedded base
  colour, ORM and OpenGL normal maps. Nose is -Z in these Y-up glTF exports.
- exports/*LOD0/1/2.obj and .mtl: explicit normal/UV geometry; the MTL links the
  current external base-colour maps. OBJ source is Z-up, metres, nose -X.
- textures/: per-LOD current BaseColor, ORM, Height and tangent-space NormalGL maps.
  Resolutions are 4096 / 2048 / 1024. ORM channels are R=AO, G=roughness, B=metallic.
  Height is an authoring aid; normal relief is the game implementation.
- source/: original numeric geometric profiles, mesh data and artist UV/normal data.
  The supplied textures and packed scene are the current service-detail artwork.
- RuntimeSource/: reviewed Lua adapters, explicit mesh arrays and mounting profiles.
  Runtime uses centimetres, +X nose/+Z up, and the existing game material.
- GameMaps/: current C/MRX/NO input maps, supplied as original PNGs for conversion.
  NO uses the game's packing and differs from the standard OpenGL normal PNG.
- RuntimeTexturePayload/: the three original reviewed cooked containers. They contain
  authored textures, not a proprietary game material or shader library.

Source art is right handed: +X aft, +Y lateral, +Z up. Body length is 5.20 m.
Dimensions and cosmetic details are photo-derived estimates, not engineering data.

The packed Blender scene can be opened directly; no numpad is required. Select
F22Tank_LOD0 in the Outliner and choose View > Frame Selected. Use the top-right
shading spheres for Material Preview or Rendered view. LOD1/LOD2 are hidden initially.

## Rebuilding and adapting

Native scene editing uses Blender 5.2.3. Match the axis/unit conventions above when
exporting. The current native scene and plain PNGs are the preferred starting point
for changes. The numeric JSON data can also be imported into your own tooling.
Changing geometry requires new UV/normal baking and revalidation.

Rebuilding AC8 cooked containers requires a compatible Unreal/game-specific toolchain
and your own game installation; those prerequisites, mappings, engine binaries and
extracted game assets are not included. The supplied RuntimeTexturePayload is the
reviewed binary output. See the Project Pileus and retoc/CUE4Parse links in CREDITS.md.
Do not package the original game's material/shader libraries with an adaptation.

## Reuse

MIT license covers original code, geometry, texture artwork and documentation.
Retain LICENSE.txt and CREDITS.md and identify your changes. Third-party tools and
reference photos have their own terms and are not included. No official aircraft
engineering, manufacturer/publisher endorsement or multiplayer compatibility is claimed.

