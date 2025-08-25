import SwiftUI
import FirebaseCore

@main
struct StudyGardenMacApp: App {
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


