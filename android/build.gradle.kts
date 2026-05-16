allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null) {
            // Force compileSdkVersion to 36 for all modules to satisfy Java 9+ requirements
            android.compileSdkVersion(36)
            
            if (android.namespace == null) {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestContent = manifestFile.readText()
                    val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestContent)
                    if (packageMatch != null) {
                        android.namespace = packageMatch.groupValues[1]
                    }
                }
            }

            // Patch compile options for JVM compatibility across all plugins
            android.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
            android.compileOptions.targetCompatibility = JavaVersion.VERSION_17
            
            // Modern compilerOptions DSL for Kotlin 2.0+
            project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
