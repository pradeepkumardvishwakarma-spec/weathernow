# Flutter's own required keep rules are applied automatically by the
# Flutter Gradle plugin. Most plugins used here (dio, hive_flutter,
# connectivity_plus, go_router, cached_network_image, flutter_dotenv) ship
# their own consumer ProGuard rules bundled in their AAR, so this file only
# needs the couple of things that commonly trip up R8 on a fresh Flutter
# release build.

# R8 sometimes warns about Play Core classes referenced by Flutter's
# deferred-components support even when it's unused (as here) - suppress
# rather than pulling in the play-core dependency just to silence it.
-dontwarn com.google.android.play.core.**
