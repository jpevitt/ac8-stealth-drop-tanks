# Stealth Drop Tanks 0.4.6 — public beta, 2026-10-24

## Included

- Shared original tank/pylon asset for F-22, EA-36 and FA-36.
- Light-grey satin paint, dark upper pylon, rectangular service cover, restrained
  wear and normal-map attachment hardware/fastener detail.
- Native mounting profiles for EA-36/FA-36; accepted F-22 placement retained.
- Original opaque game shader with original C/MRX/NO virtual textures.
- Native asset-loading and preview teardown safeguards for aircraft changes.
- Cached visibility synchronization, restart stock suppression and paced release
  handoff. Native collision, attachment, fuel and jettison physics retained.

## Validation

Manual recordings support F-22 hangar/mission/restart/release and EA-36/FA-36
hangar/aircraft changes/mission/restart/release in the reviewed scenarios. The former
FA-36 switch crash did not recur in the latest reviewed run. Offline checks cover
24 simulated swaps, invalidated assets, teardown, material fallback, restart and
all-LOD rigid mounting/F-22 geometry identity. No additional in-game test was run
during distribution packaging.

The public package has the exact reviewed 0.4.6 runtime Lua, mesh arrays and three
cooked containers. Changes for publication are documentation, metadata and packaging.
Unused legacy runtime PNGs, review-only installers/tests, recordings and private
inspection material are excluded.

## Known issues and limits

A brief cosmetic hangar appearance delay remains intentionally deferred. A small
release silhouette/ghosting artifact remains, clearest on the first banked FA-36 drop;
its exact cause is unproven. Default fixed LOD0 has no automatic distance switching.
F-35 and unlisted aircraft are excluded. Compatibility beyond the documented
environment is unverified.

## Version history

0.4.6: measured EA-36/FA-36 crown seating; native material loading; safer preview
cleanup and owner validation. 0.4.5: first EA-36/FA-36 expansion, superseded after
mounting and switch-crash findings. 0.4.4: accepted F-22 restart suppression.
0.4.3: rectangular cover and pylon attachment details. 0.4.2: working game-shader
and original virtual-texture detail integration. Geometry asset version remains 0.5.1.

