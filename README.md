# Nova Mod Menu — Null's Brawl 70.877 (arm64)

This Theos tweak builds a UIKit floating overlay for bundle ID `nt.nb.ios`.

## Implemented in this starter build
- Floating entry point (fixed-position bubble) and menu panel.
- iOS document picker import for `.NullsBrawlAssets` and `.zip` files.
- Copies imported files into the app's `Documents/Mods` directory.
- Persists imported archive list and enabled/disabled flags using `NSUserDefaults`.
- Removes imported archives from the app's Mods directory.

## Important functional boundary
The uploaded game executable and asset example are not available in this build workspace, and no verified runtime mod-loader API or asset activation path has been established. Therefore the enabled switch currently persists manager state only. It does **not** claim to alter gameplay, inject models, change skins, or activate assets. Those require reverse-engineering the exact 70.877 loader and validating the archive schema. Do not treat this UI as a functioning gameplay mod loader yet.

## Build with GitHub Actions from Windows
1. Create a new GitHub repository and upload this folder's contents.
2. Add the workflow at `.github/workflows/build.yml` (provided in the project).
3. Push to the `main` branch or run the workflow manually.
4. Download the `NovaModMenu-build` artifact. It contains the compiled `.dylib` if the toolchain build succeeds, plus the Theos package output.
5. Inject the dylib into a copy of your IPA with your signing/injection tool and re-sign the app. Keep an untouched backup.

The GitHub runner is a macOS build host; your Windows PC only needs a browser.
