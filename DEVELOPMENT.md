# Development and repository layout

This is a clean distribution source snapshot of runtime 0.4.6 / geometry 0.5.1.
Historical development branches and private inspection tools are not published.

- F22LDTPTrial/Scripts: runtime lifecycle, geometry, game material and aircraft mount adapters.
- F22LDTPTrial/Settings.lua: user configuration; retain the legacy folder identity.
- source/profile.json: photo-derived shape and dimensional profile.
- AUTHORING.md: editable asset conventions, channel packing and adaptation guide.
- Verify.ps1: read-only player package/installation verifier; run from the extracted player ZIP.
- release-assets.json: hashes identifying the reviewed generated runtime dependencies.

To work on runtime code, extract the player ZIP, then replace its matching Lua files
with this repository's versions. The generated Assets/LOD0.lua through LOD2.lua and
TexturePayload files must remain present; source checkout alone cannot run the mod.
Obtain UE4SS and AC8 Mod Loader separately as described in INSTALL.md.

For modelling or texture edits, use the authoring ZIP's packed Blender scene, current
PNGs and numeric mesh/UV/normal files. Keep source axes/units, mirrored symmetry and
the existing opaque game material conventions. Conversion requires your own compatible
Unreal/game toolchain. This repository does not claim to provide a one-command rebuild
of the cooked payload. Original game assets, mappings, keys and tool binaries are excluded.

Game tests are manual. Review hangar fitting, aircraft switching, missions, restart,
jettison and removal/rollback after runtime or material changes. Preserve a known-good
build. Keep the documented hangar delay as an accepted limitation.

The original developer workspace remains separate. Make future public changes in a
clone of this repository; never push the private workspace's historical Git database.
Retain MIT and community credit notices when adapting the work.
