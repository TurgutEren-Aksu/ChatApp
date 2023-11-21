import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
struct Message: Identifiable, Hashable {
	var id: String
	var senderID: String
	var content: String
	var isCurrentUser: Bool
	var senderUsername: String
	
	init(id: String, senderID: String, content: String, isCurrentUser: Bool, senderUsername: String) {
		self.id = id
		self.senderID = senderID
		self.content = content
		self.isCurrentUser = isCurrentUser
		self.senderUsername = senderUsername
	}
}
