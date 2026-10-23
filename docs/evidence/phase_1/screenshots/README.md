# Headless rendered previews

These PNGs were captured from real Flutter widgets at 390×844 logical pixels, 2× image resolution. They are not Android/iOS device screenshots. The shell, themes and five generated locales are the actual application code.

Capture-only fonts: DejaVu Sans from the host, Noto Sans HK, SC, JP and Thai from the official google/fonts repository, loaded locally by the optional capture test into the declared system fallback families. They are not bundled into the app or fetched at app startup. CJK regional typography, native text rasterization and system accessibility still require real mobile QA. Material icons are loaded from the Flutter asset bundle. Image precaching ensures the original KeEv logo is present before capture.

Capture command (paths refer to local font files supplied for the optional tool):

```sh
flutter test tools/capture_shell_test.dart \
  --dart-define=CAPTURE_CJK_FONT=/absolute/path/NotoSansHK.ttf \
  --dart-define=CAPTURE_SC_FONT=/absolute/path/NotoSansSC.ttf \
  --dart-define=CAPTURE_JP_FONT=/absolute/path/NotoSansJP.ttf \
  --dart-define=CAPTURE_THAI_FONT=/absolute/path/NotoSansThai.ttf
```

`CAPTURE_FONT` can override the Latin font path. The application itself does not read these capture defines. Fonts were obtained from `https://github.com/google/fonts/tree/main/ofl/notosanshk` and `https://github.com/google/fonts/tree/main/ofl/notosansthai` for QA only.
