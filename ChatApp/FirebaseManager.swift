import Foundation
import FirebaseDatabaseInternal
import Firebase
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager: ObservableObject {
	static let shared = FirebaseManager()
	@Published var loginStatusMessage = ""
	@Published var loggedIn = false
	@Published var message : [Message] = []
	let auth = Auth.auth()
	let storage = Storage.storage()
	let database = Database.database().reference()
	@Published var senderUsername: String = ""
	@Published var lastSeen: Date?
	@Published var shouldNavigateToMessageView = false
	let firestore = Firestore.firestore()
	
	init() {
		observeMessages()
	}
	private func observeMessages() {
		database.child("messages").observe(.childAdded) { snapshot, _ in
			if let messageData = snapshot.value as? [String: Any],
			   let id = messageData["id"] as? String,
			   let senderID = messageData["senderID"] as? String,
			   let content = messageData["content"] as? String,
			   let senderUsername = messageData["senderUsername"] as? String,
			   let senderEmail = messageData["senderEmail"] as? String,
			   let timestampString = messageData["timestamp"] as? String,
			   let timestamp = Double(timestampString){
				
				let isCurrentUser = senderID == Auth.auth().currentUser?.uid
				let message = Message(id: id, senderID: senderID, content: content, isCurrentUser: isCurrentUser, senderUsername: senderUsername, senderEmail: senderEmail,timestamp: Date(timeIntervalSince1970: timestamp))
				self.message.append(message)
			}
		}
	}
	
	func sendMessageToFirebase(message: Message, senderUsername: String, senderEmail: String) {
		let messageData: [String: Any] = [
			"id": message.id,
			"senderID": message.senderID,
			"content": message.content,
			"senderUsername": senderUsername,
			"senderEmail": senderEmail,
			"timestamp": String(message.timestamp.timeIntervalSince1970)
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
			self.handleSuccess(message: "Giriş işlemi başarılı", userID: result?.user.uid, email: result?.user.email ?? "")
		}
	}
	
	func newAccount(email: String, password: String) {
		auth.createUser(withEmail: email, password: password) { result, error in
			if let error = error {
				self.handleAuthError(error: error)
				return
			}
			self.handleSuccess(message: "Kullanıcı oluşturma başarılı", userID: result?.user.uid, email: result?.user.email ?? "")
		}
	}
	private func handleAuthError(error: Error){
		self.loginStatusMessage = "Hata: \(error.localizedDescription)"
		self.loggedIn = false
	}
	func handleSuccess(message:String, userID:String?,email: String){
		print("\(message) \(userID ?? "")")
		self.loginStatusMessage = "\(message) \(userID ?? "")"
		self.loggedIn = true
		self.shouldNavigateToMessageView = true
		let collectionRef = firestore.collection("collectionName")
		
		// Replace "documentId" with the desired document ID or let Firestore auto-generate it
		let documentRef = collectionRef.document(userID!)
		
		// Replace "fieldValue" and "anotherFieldValue" with your data
		let data: [String: Any] = [
			"uid": "\(userID!)",
			"email": "\(email)"
		]
		
		// Add the data to Firestore
		documentRef.setData(data) { error in
			if let error = error {
				print("Error adding document: \(error)")
			} else {
				print("Document added successfully!")
			}
		}
		
	}
	func usernameFromEmail(email: String) -> String {
		guard let atIndex = email.firstIndex(of: "@") else {
			return email
		}
		return String(email.prefix(upTo: atIndex))
	}
	func fetchMessages(){
		
	}
	func updateUserLastSeen() {
		if let currentUser = Auth.auth().currentUser {
			let database = Database.database().reference().child("users").child(currentUser.uid)
			let timestamp = ServerValue.timestamp()
			database.updateChildValues(["lastSeen": timestamp]) {error, _ in
				if let error = error {
					print("Hata oluştu: \(error.localizedDescription)")
				}else{
					print("Son Görülme Bilgisi Güncellendi")
					self.lastSeen = Date()
				}
			}
			lastSeen = Date()
		}
	}
	let yourDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}()
}
