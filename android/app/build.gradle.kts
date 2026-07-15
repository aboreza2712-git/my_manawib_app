import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. قراءة آمنة لملف key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { stream ->
        keystoreProperties.load(stream)
    }
}

android {
    namespace = "com.yousif.manawib"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // تم تحديث جافا هنا لحل تحذير الـ Deprecation
    kotlinOptions {
        jvmTarget = "17"
    }

    // 2. إعداد التوقيع (يجب تعريفه قبل الـ buildTypes والـ defaultConfig في Kotlin DSL)
   signingConfigs {
        create("release") {
            keyAlias = "upload"
            keyPassword = "Rezareza22"
            storePassword = "Rezareza22"
            
            // تحديد مسار ملف الـ jks الفعلي الموجود داخل مجلد app
            storeFile = file("upload-keystore.jks") 
        }
    }

    defaultConfig {
        applicationId = "com.yousif.manawib"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            // ربط التوقيع الذي قمنا بإنشائه بالأعلى
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}