import SwiftUI
import Firebase
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
	let didComplereLoginProcess: () -> ()
	@StateObject private var viewModel = FirebaseManager()
	@State private var isLoginHere = false
	@State private var email = ""
	@State private var password = ""
	
	var body: some View {
		NavigationView {
			ScrollView {
				VStack(spacing: 16) {
					Picker(selection: $isLoginHere, label: Text("Picker Here")) {
						Text("Login").tag(true)
						Text("Create Account").tag(false)
						
					}
					.pickerStyle(SegmentedPickerStyle())
					.padding()
					
					if !isLoginHere {
						
					}
					
					Group {
						TextField("Email", text: $email)
							.keyboardType(.emailAddress)
							.autocapitalization(.none)
						
						SecureField("Password", text: $password)
					}
					.padding(12)
					.background(Color.white)
					
					
					
					NavigationLink(
						destination: MessageView(),
						isActive: $viewModel.shouldNavigateToMessageView,
						label: {
							Button {
								handleAction()
							} label: {
								HStack {
									Spacer()
									Text(isLoginHere ? "Log In" : "Create Account")
										.font(.system(size: 20, weight: .semibold))
										.foregroundColor(.white)
										.padding(.vertical, 10)
									Spacer()
								}
							}
							.background(Color.blue)
						}
					)
					
					Text(viewModel.loginStatusMessage)
						.foregroundColor(.red)
				}
				.padding()
			}
			.navigationTitle(isLoginHere ? "Login" : "Create Account")
			.background(Color("newGray"))
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
	
	private func handleAction() {
		if isLoginHere {
			viewModel.loginUser(email: email, password: password)
		} else {
			viewModel.newAccount(email: email, password: password)
		}
	}
}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(didComplereLoginProcess: {
			
		})
	}
}
