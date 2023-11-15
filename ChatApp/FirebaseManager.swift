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
	private let database = Database.database().reference()
	
	init() {
		//		FirebaseApp.configure()
		self.auth = Auth.auth()
		observeMessage()
	}
	private func observeMessages() {
		database.child("messages").observe(.childAdded) { snapshot in
			if let messageData = snapshot.value as? [String: String],
			   let id = messageData["id"],
			   let senderID = messageData["senderID"],
			   let content = messageData["content"] {
				let message = Message(id: id, senderID: senderID, content: content)
				self.messages.append(message)
			}
		}
	}
	private func sendMessageToFirebase(message: Message) {
		let messageData: [String: String] = [
			"id": message.id,
			"senderID": message.senderID,
			"content": message.content
		]
		database.child("messages").child(message.id).setValue(messageData)
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
