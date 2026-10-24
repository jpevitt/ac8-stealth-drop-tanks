# Credits and redistribution

Original modelling, texture artwork, Lua runtime and documentation: ampcackl, with
Codex assistance, 2026. Original project contributions are offered under MIT;
retain LICENSE.txt and CREDITS.md. Geometry and pixels are authored by this project.
Photos/recordings informed appearance; they are not included. Names are descriptive
and imply no manufacturer, military, publisher or other mod-author endorsement.

# Reused community work

- Project Pileus / Nimbus Custom Works (M4rkoz and contributors): documented AC8
  virtual-texture cook, C/MRX/NO channel packing and compression settings.
  https://www.nexusmods.com/acecombat8wingsoftheve/mods/87?tab=description
  No template art or third-party textures are included in this tank package.
- trumank, retoc 0.1.5 (MIT): used unchanged for game package inspection, UE5_4
  container conversion, verification and byte round-trip checks.
  https://github.com/trumank/retoc
- JustMonika24769, AC8OverrideToolkit (MIT): its published AC8 mappings were used
  unchanged for local property inspection; its extraction/round-trip workflow informed
  validation. The mappings and toolkit are development dependencies, not bundled here.
  https://github.com/JustMonika24769/AC8OverrideToolkit
- FModel / CUE4Parse: the existing local parser binaries were reused to inspect the
  original game's material parameters and independently parse all converted textures.
  Neither their libraries nor extracted game assets are redistributed.
  https://github.com/4sval/FModel
  https://github.com/FabianFG/CUE4Parse
- GHFear / Illusory Software, AES Dumpster: used as a local static inspection tool.
  Its remote-submission callback was removed and network access blocked before use.
  Tool code, scan output and keys stay private and are excluded from redistribution.
  https://illusory.dev/aesdumpster/
- Existing locally installed AC8 Mod Loader 1.3.1: reused without rebuilding inside
  the existing loader identity to register new texture packages. Obtain it separately:
  https://www.nexusmods.com/acecombat8wingsoftheve/mods/64
  No loader or launcher binary is included in either distribution archive.

The runtime references the original game's material by path. It does not redistribute
the game's material, shader library, texture pixels, engine global containers or codec.
Original tank code and texture artwork remain under the project's MIT license.

- UE4SS-RE contributors (MIT): runtime Lua/reflection framework, installed separately.
  https://github.com/UE4SS-RE/RE-UE4SS
- Blender, Python, Pillow and NumPy: authoring/build tools, installed separately.
  None of their binaries or libraries are bundled.

The separate loader/launcher has its own distribution permissions. This package
references it as a prerequisite and redistributes none of its files. No generic
claim of permission to redistribute third-party tools is made by the project's MIT
license. Supplied shader texture artwork is original; the game material is referenced
by path and is not included. Recommended attribution: Stealth Drop Tanks by ampcackl
(MIT), runtime 0.4.6 / geometry 0.5.1; adapted by [your name].
