import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View {
	@EnvironmentObject private var viewModel: FirebaseManager
	@State private var messageText: String = ""
	
	var body: some View {
		VStack {
			List(viewModel.message, id: \.self) { message in
				VStack(alignment: message.isCurrentUser ? .trailing: .leading){
					Text("\(viewModel.usernameFromEmail(email: message.senderEmail)): \(message.content)")
						.padding(10)
						.background(message.isCurrentUser ? Color.blue : Color.gray)
						.foregroundColor(.white)
						.cornerRadius(10)
						.frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
					Text("\(message.timestamp, formatter: yourDateFormatter)")
						.font(.caption)
						.foregroundColor(.gray)
				}
			}
			
			HStack {
				TextField("Type a message: ", text: $messageText)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding(.horizontal)
				
				Button("Send") {
					sendMessage()
				}
				.padding(.trailing)
			}
		}
		.navigationTitle("Chat")
	}
	
	private func sendMessage() {
		if !messageText.isEmpty {
			let isCurrentUser = true
			if let currentUser = Auth.auth().currentUser{
				let timestamp = Date()
				let message = Message(id: UUID().uuidString, senderID: "your_sender_id", content: messageText, isCurrentUser: isCurrentUser, senderUsername: viewModel.senderUsername, senderEmail: currentUser.email ?? "", timestamp: timestamp)
				viewModel.sendMessageToFirebase(message: message, senderUsername: viewModel.senderUsername, senderEmail: currentUser.email ?? "")
			}
			messageText = ""
		}
	}
	let yourDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}()
}

struct ChatView_Previews: PreviewProvider {
	static var previews: some View {
		ChatView()
	}
}
