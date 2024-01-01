
import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct RecentMessage: Codable ,Identifiable {
	
	@DocumentID var id: String?
	
	let sourceId, destinationId: String
	
	let messageText,email: String
	
	let timestamp: Date

}
