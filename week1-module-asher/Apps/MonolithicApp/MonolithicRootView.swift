import SwiftUI

struct MonolithicRootView: View {
    var body: some View {
        TabView {
            Tab("Camera", systemImage: "camera") {
                MonolithicCameraScreen()
            }

            Tab("Detect", systemImage: "viewfinder") {
                MonolithicDetectScreen()
            }

            Tab("Edit", systemImage: "film.stack") {
                MonolithicVideoEditScreen()
            }

            Tab("Settings", systemImage: "gearshape") {
                MonolithicSettingsScreen()
            }
        }
        .tint(MonolithicAppTheme.accent)
    }
}

