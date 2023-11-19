import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
// ...
	  

struct Message: Identifiable, Hashable {
	var id: String
	var senderID: String
	var content: String
}
