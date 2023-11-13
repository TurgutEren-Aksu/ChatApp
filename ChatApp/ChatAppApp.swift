//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 13.10.2023.
//

import SwiftUI
import FirebaseCore

@main
struct ChatAppApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject private var viewModel = FirebaseManager()
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(viewModel)
			
		}
	}
}
