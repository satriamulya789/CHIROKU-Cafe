buildscript {
    val kotlin_version by extra("2.1.0")
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        // Firebase Google Services plugin
        classpath("com.google.gms:google-services:4.4.0")
    }
}
plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
    // Tambahkan plugin lain jika perlu
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// (Opsional, jika ingin custom build dir)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

