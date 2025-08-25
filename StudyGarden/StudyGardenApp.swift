import SwiftUI
import FirebaseCore

@main
struct StudyGardenApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    configureFirebaseIfNeeded()
                }
        }
    }
}

private func configureFirebaseIfNeeded() {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        configureFirebaseIfNeeded()
        return true
    }
}
#endif
