# CosmoKundli App

Flutter client for CosmoKundli. Same backend, APIs, controllers and models as the
original app; the UI is rebuilt in the **liquid-glass** language of the CosmoKundli
desktop software (deep-space backdrop, frosted glass cards, orange CTA gradient,
floating glass dock, springy motion).

## Where the design lives
- `lib/ui/ck_theme.dart` — design tokens (colors, radii, motion) + dark `ThemeData`
- `lib/ui/glass.dart` — `CkScaffold`, `Glass`, `Pressable`, `FadeSlideIn`, `CkHeading`, `GlassTile`
- `lib/custom_widgets/` — shared app bar, floating bottom dock, buttons, fields, tabs, loader
- `lib/values/colors.dart` — legacy color names remapped to the new palette

## Building the APK (GitHub only)
Every push to `main` runs `.github/workflows/build-apk.yml` (Flutter 3.29.3, Java 17):
`flutter pub get` → `flutter analyze` → `flutter build apk --release`.
Download the APK from the run's **Artifacts → CosmoKundli-APK**.

Trigger manually from the CLI:
```bash
gh workflow run build-apk.yml -R digitalcosmo/CosmoKundli-App
gh run watch -R digitalcosmo/CosmoKundli-App
gh run download -R digitalcosmo/CosmoKundli-App -n CosmoKundli-APK
```

> Release builds are signed with the debug key (as in the original app). Add a
> keystore before publishing to the Play Store.
