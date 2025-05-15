# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt

# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Application specific classes
-keep class com.maztafarma.cbo.** { *; }

# Basic Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.android.material.** { *; }

# Keep your application class
-keep class com.example.test_cbo.** { *; }

# Add this to preserve the line numbers for crash reporting
-keepattributes SourceFile,LineNumberTable

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the BuildConfig
-keep class com.maztafarma.cbo.BuildConfig { *; }

# Keep the support library
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# R8 specific rules
-allowaccessmodification
-repackageclasses '' 

# Keep R
-keep class **.R
-keep class **.R$* {
    <fields>;
} 