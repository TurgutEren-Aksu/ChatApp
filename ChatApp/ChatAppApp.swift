import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct ChatAppApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	@StateObject private var viewModel = FirebaseManager()
	var body: some Scene {
		WindowGroup {
			NavigationView{
				ContentView()
					.environmentObject(viewModel)
			}
		}
	}
}
