import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseConstants{
	static let sourceID = "sourceID"
	static let destinationID = "destinationID"
	static let messageText = "messageText"
	
}
class ChatMessage: Identifiable {
	var id: String { documentID }
	let documentID: String
	let sourceID, destinationID, messageText: String
	init(documentID: String, data: [String: Any]) {
		self.documentID = documentID
		self.sourceID = data[FirebaseConstants.sourceID] as? String ?? ""
		self.destinationID = data[FirebaseConstants.destinationID] as? String ?? ""
		self.messageText = data[FirebaseConstants.messageText] as? String ?? ""
	}
}

class SendButton: ObservableObject{
	@Published var chatMessages = [ChatMessage]()
	@Published var messageText = ""
	@Published var errorMessage = ""
	let chatUser: ChatUser?  
	
	

	init(chatUser: ChatUser?){
		self.chatUser = chatUser
		fetchMessages()
	}
	private func fetchMessages(){
		guard let sourceID = FirebaseManager.shared.auth.currentUser?.uid else { return }
		
		guard let destinationID = chatUser?.uid else { return }
		FirebaseManager.shared.firestore
			.collection("messages")
			.document(sourceID)
			.collection(destinationID)
			.addSnapshotListener { querySnapshot, error in
				if let error = error {
					self.errorMessage = "Mesajları çekme işlemi başarısız oldu \(error)"
					print(error)
					return
				}
				querySnapshot?.documents.forEach({ queryDocumentSnapshot in
					let data = queryDocumentSnapshot.data()
//					let chatMessage = ChatMessage(data: data)
					let docID = queryDocumentSnapshot.documentID
					self.chatMessages.append(.init(documentID: docID, data: data))
				})
			}
	}
	func handleSend(){
		print(messageText)
		guard let sourceID = FirebaseManager.shared.auth.currentUser?.uid else { return }
		
		guard let destinationID = chatUser?.uid else { return }
		let document =
		FirebaseManager.shared.firestore
			.collection("messages")
			.document(sourceID)
			.collection(destinationID)
			.document()
		
		let messageCollection = [FirebaseConstants.sourceID: sourceID,
								 FirebaseConstants.destinationID: destinationID,
								 FirebaseConstants.messageText: self.messageText,
								 "timestamp" : Timestamp() ] as [String : Any]
		
		document.setData(messageCollection) { error  in
			if let error = error {
				print(error)
				self.errorMessage = "Firestore'a gönderme işlemi başarısız oldu\(error)"
			}
			self.messageText = ""
		}
		let destinationMessageDocument =
		FirebaseManager.shared.firestore
			.collection("messages")
			.document(destinationID)
			.collection(sourceID)
			.document()
		destinationMessageDocument.setData(messageCollection) { error  in
			if let error = error {
				print(error)
				self.errorMessage = "Firestore'a gönderme işlemi başarısız oldu\(error)"
			}
		}
	}
}
struct ChatView: View{
	
	let chatUser: ChatUser?
	init(chatUser: ChatUser?){
		
		self.chatUser = chatUser
		self.vm = .init(chatUser: chatUser)
	}
	
	@State var messageText = ""
	@ObservedObject var vm: SendButton
	
	var body: some View{
		ZStack {
			messageTopBar
			Text(vm.errorMessage)
		}
		
		.navigationTitle(chatUser?.email ?? "")
		.navigationBarTitleDisplayMode(.inline)
	}
	private var messageTopBar: some View {
		VStack{
			if #available(iOS 15.0, *){
				ScrollView{
					ForEach(vm.chatMessages) { message in
//						Text(message.messageText)
//					}
//					ForEach(0..<30){ num in
						HStack{
							Spacer ()
							HStack{
								Text(message.messageText)
									.foregroundStyle(.white)
							}
							.padding( )
							.background(Color.blue)
							.cornerRadius(8)
							
						}
						.padding(.horizontal)
						.padding(.top, 8)
						
					}
					HStack{ Spacer() }
					
				}
				.background(Color(.init(white: 0.95, alpha: 1)))
				.safeAreaInset(edge: .bottom) {
					chatBottomBar
						.background(Color(.systemBackground).ignoresSafeArea())
				}
			}else {
				
			}
		}
	}
	private var chatBottomBar: some View {
		HStack(spacing: 16){
			ZStack {
				DescriptionPlaceholder()
				TextEditor(text: $vm.messageText)
					.opacity(vm.messageText.isEmpty ? 0.5 : 1)
			}
			.frame(height: 40)
			Button {
				vm.handleSend()
			} label: {
				Text("Send")
					.foregroundStyle(Color(.white))
				
			}
			.padding(.horizontal)
			.padding(.vertical, 8 )
			.background(Color.blue)
			.cornerRadius(8)
			
		}
		.padding(.horizontal)
		.padding(.vertical, 8)
	}
}
private struct DescriptionPlaceholder: View {
	var body: some View {
		HStack {
			Text("Description")
				.foregroundColor(Color(.gray))
				.font(.system(size: 17))
				.padding(.leading, 5)
				.padding(.top, -4)
			Spacer()
		}
	}
}

#Preview {
//	NavigationView{
//		ChatView(chatUser: .init(data: ["uid" : "REAL USER UID", "email" : "eren3@gmail.com"]))
//	}
	MessageView()
}
