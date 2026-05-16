# =============================================================================
# FLUTTER - Keep all Flutter classes
# =============================================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# =============================================================================
# FLUTTER GEMMA / TENSORFLOW LITE - Keep ML classes
# =============================================================================
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class com.google.ai.edge.litert.** { *; }
-keep class io.github.flutter_gemma.** { *; }
-keep class **.*Model* { *; }
-keep class **.*Inference* { *; }
-keep class **.*Session* { *; }
-keep class **.*Message* { *; }
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.ai.edge.litert.**

# =============================================================================
# GOOGLE PLAY CORE - Ignore missing classes (not using deferred components)
# =============================================================================
# These classes are only needed for Play Store dynamic feature delivery
# Safe to ignore for standard APK builds
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# =============================================================================
# MEDIAPIPE - Ignore missing proto classes (optional dependency)
# =============================================================================
-dontwarn com.google.mediapipe.**
-keep class com.google.mediapipe.** { *; }

# =============================================================================
# GENERAL - Keep common patterns
# =============================================================================
# Keep classes referenced via reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
  public static final ** CREATOR;
}

# Keep Serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep native method classes
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep R (resource) classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# =============================================================================
# SUPPRESS WARNINGS - For classes that may not be present at runtime
# =============================================================================
-dontwarn sun.misc.**
-dontwarn java.nio.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**
-dontwarn org.apache.commons.**