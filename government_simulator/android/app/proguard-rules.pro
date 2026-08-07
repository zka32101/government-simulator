# Keep rules for release builds (isMinifyEnabled/isShrinkResources are now on).
# Flutter's own engine classes are kept automatically by the Flutter Gradle
# plugin; the rules below cover plugins used by this app that rely on
# reflection and would otherwise break when R8 renames/strips classes.

# Firebase (Firestore model (de)serialization uses reflection)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# RevenueCat (purchases_flutter)
-keep class com.revenuecat.purchases.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Keep annotations & generic signatures needed by the above
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
