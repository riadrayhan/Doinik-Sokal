# doinik_sokal2

A new Flutter project.

## Getting Started

## apk release command
<p>keytool -genkey -v -keystore C:/Users/Riad/jks_filepath/doinik-sokal.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload</p>

<h3>key.properties in android folder</h3>
<ui>storePassword=coderfleek</ui>
<ui>keyPassword=coderfleek</ui>
<ui>keyAlias=upload</ui>
<ui>storeFile=../app/doinik-sokal.jks</ui>


<h3>build.gradle</h3>

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

<p>above android{}</p>

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
        }
    }
}

flutter {
    source = "../.."
}




A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
