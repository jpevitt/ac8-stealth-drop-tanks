# Installation, update, removal and troubleshooting

## 1. Find the active runtime

Close the game and launcher before changing files. Install a working AC8-compatible
UE4SS setup and AC8 Mod Loader 1.3.1 separately, following their authors' instructions.

The usual active directory is:

    ACE COMBAT 8\Game\Binaries\Win64\ue4ss\Mods

AC8FOV installations can instead use:

    ACE COMBAT 8\Game\Binaries\Win64\AC8FOV\runtime\Mods

Check Win64\override.txt and the current UE4SS.log: the log identifies the runtime's
active Mods directory. A launcher may maintain a separate source library and copy
mods into the runtime at launch. Import/install into that library as required by the
launcher, then verify its resulting active runtime. Updating only the runtime can be
overwritten by the next launcher sync. Keep only one active F22LDTPTrial copy.

The loader is normally named IoStoreLoaderMod. Some existing installations retain
the name AC8OverrideLoader with the same tested 1.3.1 DLL. The folder name does not
upgrade an older DLL. Keep one active new-package-capable loader; preserve other
mods' payloads and the loader's settings.

## 2. First installation

1. Extract the public beta ZIP somewhere outside the game.
2. Run Verify.ps1 there to check every supplied file.
3. Copy F22LDTPTrial into your active UE4SS Mods directory.
4. Inside the active loader folder, create payloads if necessary. Copy the entire
   TexturePayload\F22Shader03 folder into payloads.
5. Enable F22LDTPTrial and the existing loader in your manager. The supplied empty
   enabled.txt supports UE4SS automatic loading. An explicit "F22LDTPTrial : 0"
   in mods.txt overrides that; change it through your manager or enable the entry.
6. Verify the installed files, using the active Mods directory and actual loader name.
7. Start using your established offline launch method. Select F-22, EA-36 or FA-36
   and equip the normal Drop Tank part.

Standard resulting layout:

    ue4ss\Mods\
      F22LDTPTrial\
        enabled.txt
        Settings.lua
        manifest.json
        Scripts\main.lua, geometry.lua, material.lua, mounts.lua
        Assets\LOD0.lua, LOD1.lua, LOD2.lua
        README.md, RELEASE_NOTES.md, CREDITS.md, LICENSE.txt
      IoStoreLoaderMod\
        dlls\main.dll                         [separate prerequisite]
        payloads\F22Shader03\
          F22Shader03_P.pak
          F22Shader03_P.utoc
          F22Shader03_P.ucas

Do not install the Lua folder into Paks/~mods. This package's prescribed payload
location is inside the active loader. No Steam launch setting or anti-cheat file is
changed by this package. WingmanDropTanks and PGM are not required for player tanks;
wingman tank visibility depends on the game or whatever mod supplies those tanks.

## 3. Update an existing version

Back up the existing F22LDTPTrial folder and F22Shader03 payload folder **outside
active Mods and Paks/~mods directories**. Keep your old Settings.lua for reference.
Replace F22LDTPTrial with the new folder and update its three payload sidecars as
a complete set. Do not leave an old enabled copy beside it. Review custom settings
before reapplying them; EA-36/FA-36 mount profiles expect the supplied fixed-scale frame.

Versions through 0.4.6 review releases may contain six legacy PNGs in Assets. The
public beta removes those unused files; runtime textures come from the three cooked
containers. The runtime Lua code, mesh arrays and cooked containers are byte-identical
to the manually reviewed 0.4.6 build.

For a launcher-managed installation, update its source library as well as any active
copy it maintains. Do not replace a working loader binary with one from an old tank
release; no loader binary is included here.

## 4. Disable, uninstall or roll back

To disable: turn off F22LDTPTrial in your manager. Disable only this mod, keeping
shared loader requirements of other mods intact.

To uninstall, with the game and launcher closed:

- Remove only the F22LDTPTrial folder from your active runtime and manager library.
- Remove only the F22Shader03 payload folder from the active loader and any manager
  source library. Leave the loader, other payloads and other mods in place.
- Remove/disable any explicit F22LDTPTrial manager entry if needed.

To roll back, replace these two folders with the paired backup you made before the
update, then restore the previous enable choice. Keep all three old payload sidecars
together. This visual mod does not modify game save files.

## 5. Diagnose an installation

Run:

    .\Verify.ps1 -Mode Installed -ModsDirectory "D:\...\ue4ss\Mods"

For a loader named AC8OverrideLoader append:

    -LoaderModName AC8OverrideLoader

The verifier checks package hashes, installed Lua/mesh/container hashes, the tested
loader DLL and explicit mods.txt disabled entries. It does not start the game.

- Standard tank remains: confirm Drop Tank is equipped, correct active runtime,
  manager enable state, one active replacement and all three payload sidecars.
- No custom paint/details: check that the loader registered the nine F22Shader03
  texture packages. An old override-only loader cannot supply these new packages.
- Crash after a game/loader update: disable this mod and retain the logs before
  changing other mods. Tested compatibility does not automatically extend to updates.
- A short hangar appearance delay or minor release silhouette artifact: see known
  limitations; these do not by themselves imply an installation failure.

For a report retain trial.log from F22LDTPTrial and the relevant UE4SS.log window.
Include aircraft, skin, mission/loadout, runtime version, loader version and a short
recording/time of the issue. Inspect logs for personal paths or account data before
sharing them. Never send authentication files or the full private development workspace.

