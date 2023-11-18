import Foundation
import SwiftUI
import Firebase
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
// ...
	  

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
