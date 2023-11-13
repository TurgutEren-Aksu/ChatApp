//
//  LoggedInView.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 13.11.2023.
//

import Foundation
import SwiftUI
import Firebase

struct LoggedInView: View{
//	@StateObject private var viewModel = FirebaseManager()
	@EnvironmentObject private var viewModel: FirebaseManager
	var body: some View{
		NavigationView{
			if viewModel.loggedIn{
				NavigationLink(
					destination: ChatView(),
					label: {
						Text("Open")
					}
				)
			}else{
				Text("You are not logged in")
			}
		}
		
	}
}
