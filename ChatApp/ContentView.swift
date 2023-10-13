//
//  ContentView.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 13.10.2023.
//

import SwiftUI
import Firebase


class FirebaseManager: NSObject {
	
	let auth: Auth
	static let shared = FirebaseManager()
	override init() {
		FirebaseApp.configure()
		
		
		
		self.auth = Auth.auth()
		
		super.init()
		
	}
}

struct ContentView: View {
	
	@State var isLoginHere = false
	@State var email = ""
	@State var password = ""
	

	
    var body: some View {
		
		NavigationView{
			ScrollView{
				VStack(spacing: 16){
					Picker(selection: $isLoginHere, label: Text("Picker Here")){
						Text("Login")
							.tag(true)
						Text("Create Account")
							.tag(false)
					}.pickerStyle(SegmentedPickerStyle())
						.padding()
					if !isLoginHere{
						Button{
							
						}label: {
							Image(systemName: "person.fill")
								.font(.system(size: 64))
								.padding()
						}
					}
					Group{
						TextField("Email", text: $email)
							.keyboardType(.emailAddress)
							.autocapitalization(.none)
							
						SecureField("Password", text: $password)
							
					}.padding(12)
						.background(Color.white)
					
					
					Button{
						handleAction()
					}label: {
						HStack{
							Spacer()
							Text(isLoginHere ? "Log In" : "Create Account")
								.font(.system(size:20,weight: .semibold))
								.foregroundStyle(.white)
								.padding(.vertical,10)
								Spacer()
						}.background(Color.blue)
					}
					Text(self.loginStatusMessage)
						.foregroundColor(.red)
				}
				.padding()
				
				
			}
			.navigationTitle(isLoginHere ? "Login" : "Creat Account")
			.background(Color("newGray"))
		}
		.navigationViewStyle(StackNavigationViewStyle())
    }
	private func handleAction(){
		if isLoginHere{
			loginUser()
		}else{
			newAccount()
		}
	}
		private func loginUser(){
			FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
				if let error = error{
					print("Giriş işlemi başarısız ",error)
					self.loginStatusMessage = "Giriş işlemi Başarısız\(error)"
					return
				}
				print("Giriş işlemi başarılı \(result?.user.uid ?? "")")
				self.loginStatusMessage = "Giriş işlemi başarılı \(result?.user.uid ?? "")"
					
			}
		}
	
	
	@State var loginStatusMessage = ""
	private func newAccount(){
		FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
			if let error = error{
				print("Kullanıcı oluşturma başarısız ",error)
				self.loginStatusMessage = "Kullanıcı Oluşturma Başarısız\(error)"
				return
			}
			print("Kullanıcı oluşturma başarılı \(result?.user.uid ?? "")")
			self.loginStatusMessage = "Kullanıcı oluşturma başarılı \(result?.user.uid ?? "")"
		}
	}
}

#Preview {
    ContentView()
}

