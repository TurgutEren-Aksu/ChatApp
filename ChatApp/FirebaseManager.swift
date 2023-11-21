import Foundation
import FirebaseDatabaseInternal
import Firebase
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager: ObservableObject {
	@Published var loginStatusMessage = ""
	@Published var loggedIn = false
	@Published var message : [Message] = []
	private let auth: Auth
	private let database = Database.database().reference()
	@Published var senderUsername: String = ""
	
	init() {
		self.auth = Auth.auth()
		observeMessages()
	}
	private func observeMessages() {
		database.child("messages").observe(.childAdded) { snapshot, _ in
			if let messageData = snapshot.value as? [String: String],
			   let id = messageData["id"],
			   let senderID = messageData["senderID"],
			   let content = messageData["content"],
			   let senderUsername = messageData["senderUsername"]{
				
				let isCurrentUser = senderID == Auth.auth().currentUser?.uid
				let message = Message(id: id, senderID: senderID, content: content, isCurrentUser: isCurrentUser, senderUsername: senderUsername)
				self.message.append(message)
			}
		}
	}
	
	func sendMessageToFirebase(message: Message, senderUsername: String) {
		let messageData: [String: String] = [
			"id": message.id,
			"senderID": message.senderID,
			"content": message.content,
			"senderUsername": senderUsername
		]
		database.child("messages").child(message.id).setValue(messageData) { error, _ in
			if let error = error {
				print("Error sending message: \(error)")
			} else {
				print("Message sent successfully!")
			}
		}
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
