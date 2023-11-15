import Foundation
import SwiftUI

struct ChatView: View {
	@State private var messageText: String = ""
	@State private var messages: [String] = []
	
	var body: some View {
		VStack {
			List(messages, id: \.self) { message in
				Text(message)
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
			   let message = Message(id: UUID().uuidString, senderID: "your_sender_id", content: messageText)
			   viewModel.sendMessageToFirebase(message: message)
			   messageText = ""
		}
	}
}

struct ChatView_Previews: PreviewProvider {
	static var previews: some View {
		ChatView()
	}
}

