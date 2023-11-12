//
//  FirebaseManager.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 10.11.2023.
//

import Foundation
import Firebase

class FirebaseManager: ObservableObject {
	@Published var loginStatusMessage = ""
	@Published var loggedIn = false
	@Published var message: [Message] = []
	private let auth: Auth
	
	init() {
		FirebaseApp.configure()
		self.auth = Auth.auth()
	}
	func loginUser(email: String, password: String) {
		auth.signIn(withEmail: email, password: password) { result, error in
			if let error = error {
				self.handleAuthError(error: error)
				return
			}
			self.handleSuccess(message: "Giriş işlemi başarılı", userID: result?.user.uid)
		}
	}
	
	func newAccount(email: String, password: String) {
		auth.createUser(withEmail: email, password: password) { result, error in
			if let error = error {
				self.handleAuthError(error: error)
				return
			}
			self.handleSuccess(message: "Kullanıcı oluşturma başarılı", userID: result?.user.uid)
		}
	}
	private func handleAuthError(error: Error){
		self.loginStatusMessage = "Hata: \(error.localizedDescription)"
		self.loggedIn = false
	}
	private func handleSuccess(message:String, userID:String?){
		print("\(message) \(userID ?? "")")
		self.loginStatusMessage = "\(message) \(userID ?? "")"
		self.loggedIn = true
	}
	func fetchMessages(){
		
	}
}
