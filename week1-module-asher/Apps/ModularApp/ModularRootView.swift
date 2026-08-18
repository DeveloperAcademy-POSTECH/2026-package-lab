import Core
import FeatureCamera
import FeatureDetect
import FeatureSettings
import FeatureVideoEdit
import SwiftUI

struct ModularRootView: View {
    var body: some View {
        TabView {
            Tab("Camera", systemImage: "camera") {
                CameraScreen()
            }

            Tab("Detect", systemImage: "viewfinder") {
                DetectScreen()
            }

            Tab("Edit", systemImage: "film.stack") {
                VideoEditScreen()
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsScreen()
            }
        }
        .tint(AppTheme.accent)
    }
}

