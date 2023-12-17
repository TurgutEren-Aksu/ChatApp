import Foundation
import FirebaseDatabaseInternal
import Firebase
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager: ObservableObject {
	var contentV = ContentView(didComplereLoginProcess: {
		
	})
	static let shared = FirebaseManager()
	@Published var loginStatusMessage = ""
	@Published var loggedIn = false
	
	let auth = Auth.auth()
	let storage = Storage.storage()
	let database = Database.database().reference()
	@Published var senderUsername: String = ""
	@Published var lastSeen: Date?
	@Published var shouldNavigateToMessageView = false
	let firestore = Firestore.firestore()
	
	func loginUser(email: String, password: String) {
		auth.signIn(withEmail: email, password: password) { result, error in
			if let error = error {
				self.handleAuthError(error: error)
				return
			}
			self.handleSuccess(message: "Giriş işlemi başarılı", userID: result?.user.uid, email: result?.user.email ?? "")
			self.contentV.didComplereLoginProcess()
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
		
		let documentRef = collectionRef.document(userID!)
		
		let data: [String: Any] = [
			"uid": "\(userID!)",
			"email": "\(email)"
		]
		
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
