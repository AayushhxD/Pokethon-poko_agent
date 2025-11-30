plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.pokeagent"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.pokeagent"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // TODO: Configure release signing
            // 1. Generate keystore: keytool -genkey -v -keystore ~/pokeagent-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pokeagent
            // 2. Create android/key.properties with:
            //    storePassword=<password>
            //    keyPassword=<password>
            //    keyAlias=pokeagent
            //    storeFile=<path-to-keystore>
            // 3. Uncomment below:
            
            // val keystoreProperties = Properties()
            // val keystorePropertiesFile = rootProject.file("key.properties")
            // if (keystorePropertiesFile.exists()) {
            //     keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            // }
            // 
            // keyAlias = keystoreProperties["keyAlias"] as String
            // keyPassword = keystoreProperties["keyPassword"] as String
            // storeFile = file(keystoreProperties["storeFile"] as String)
            // storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // WARNING: Currently using debug signing. Configure release signing before production deployment.
            // See signingConfigs.release above for instructions.
            signingConfig = signingConfigs.getByName("debug")
            // After configuring release keystore, uncomment:
            // signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
