# Keep OkHttp3 classes for image_cropper/ucrop
-dontwarn okhttp3.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Keep ucrop classes
-dontwarn com.yalantis.ucrop**
-keep class com.yalantis.ucrop** { *; }
-keep interface com.yalantis.ucrop** { *; }

# Keep Okio (OkHttp dependency)
-dontwarn okio.**
-keep class okio.** { *; }

# General Android rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exception
