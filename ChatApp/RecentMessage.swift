
import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct RecentMessage: Codable ,Identifiable {
	
	@DocumentID var id: String?
	
	let sourceID, destinationID: String
	
	let messageText,email: String
	
	let timestamp: Date
	
	var username: String{
		email.components(separatedBy: "@").first ?? email
	}
	var timeago: String{
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .abbreviated
		return formatter.localizedString(for: timestamp, relativeTo: Date())
	}
}
