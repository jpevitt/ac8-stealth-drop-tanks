# Stealth Drop Tanks 0.4.6 — public beta

Original stealth-style drop-tank visual replacement for **F-22, EA-36 and FA-36**
in ACE COMBAT 8 on Windows PC. Equip the aircraft's normal **Drop Tank** part.
One shared 5.20 m tank/pylon model is used, with aircraft-specific mounting profiles.

Includes a light-grey satin coating, darker upper pylon, rectangular service cover,
restrained surface wear and attachment fasteners/relief. The service details are
artistic interpretations, not authenticated engineering drawings. Gameplay fuel,
performance, collision and release physics remain controlled by the game.

## Install

Read [INSTALL.md](INSTALL.md) before copying files. Install these separate prerequisites:

- A working AC8-compatible UE4SS offline setup. Official UE4SS project:
  https://github.com/UE4SS-RE/RE-UE4SS/releases
- **AC8 Mod Loader 1.3.1**, with support for registering new asset packages:
  https://www.nexusmods.com/acecombat8wingsoftheve/mods/64

The tested loader DLL SHA-256 is
fe79479b7346c8d30170e81d3dd759cc44c241c37bed10ce58939a1bebb08789.
The tested UE4SS log reports 3.0.1 Beta #0, commit 03dbd5c0.
Use one asset loader. An older override-only loader is insufficient.
Neither prerequisite, a launcher, an anti-cheat configuration nor an executable is bundled.

Copy the included F22LDTPTrial folder to the **active UE4SS Mods directory**.
Copy TexturePayload/F22Shader03 to **that asset loader's payloads directory**.
Keep all three texture-container sidecars together. The legacy F22LDTPTrial folder
name is intentional; it preserves existing launcher compatibility for all three aircraft.

Verify the extracted archive in PowerShell:

    .\Verify.ps1

Verify an installed standard layout:

    .\Verify.ps1 -Mode Installed -ModsDirectory "D:\Games\ACE COMBAT 8\Game\Binaries\Win64\ue4ss\Mods"

A loader renamed to AC8OverrideLoader is also supported by supplying
-LoaderModName AC8OverrideLoader. Verification is read-only and changes no settings.
Follow your loader/launcher's offline setup instructions and use offline single player.

## Supported and tested scope

The user manually reviewed hangar appearance/fit, switching between supported
aircraft, normal missions, restart and jettison. The 2026-10-24 16:11:37 recording
supports EA-36/FA-36 mission/restart/release and F-22 mission/release. Earlier F-22
recordings cover restart. This is a beta based on those scenarios, not blanket
verification of every skin, mission, game update or mod combination.

Test environment: PC Steam ACE COMBAT 8, UE 5.4.3 shipping game; Windows x64,
Blender-authored asset 0.5.1; runtime 0.4.6. The loader documents game version
1.1.2.0 compatibility; the game executable used locally is 555,102,832 bytes.
Other game builds and newer loader versions require their own compatibility review.

## Known limitations

- A brief cosmetic delay before custom tanks appear in the hangar may occur.
  This is accepted and intentionally deferred.
- A small rough/ghosted silhouette can occur during release, most noticeably on
  the first banked FA-36 drop in the reviewed recording. Both custom actors
  release correctly; the exact rendering cause is unproven.
- F-35 support is deferred. Other aircraft are excluded.
- Default rendering uses fixed LOD0, about 4,358 rendered triangles per tank.
  Automatic distance-based LOD switching is not implemented.
- Photo-derived dimensions and details are approximate. Cross-mod loadout changes
  or future game updates can require revalidation. No multiplayer support is claimed.

See [RELEASE_NOTES.md](RELEASE_NOTES.md), [CREDITS.md](CREDITS.md) and
[LICENSE.txt](LICENSE.txt). Original model, texture art and Lua code are MIT licensed.
This is an independent fan-made visual asset, with no manufacturer or publisher endorsement.

