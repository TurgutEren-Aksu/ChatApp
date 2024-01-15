import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct FirebaseConstants{
	static let sourceID = "sourceID"
	static let destinationID = "destinationID"
	static let messageText = "messageText"
	static let timestamp = Timestamp()
	static let email = "email"
	
}
struct ChatMessage: Identifiable,Decodable {
	var id: String { documentID }
	let documentID: String
	let sourceID, destinationID, messageText: String
	let email: String
	init(documentID: String, data: [String: Any]) {
		self.documentID = documentID
		self.sourceID = data[FirebaseConstants.sourceID] as? String ?? ""
		self.destinationID = data[FirebaseConstants.destinationID] as? String ?? ""
		self.messageText = data[FirebaseConstants.messageText] as? String ?? ""
		self.email = data[FirebaseConstants.email] as? String ?? ""
	}
}

class SendButton: ObservableObject{
	@Published var chatMessages = [ChatMessage]()
	@Published var messageText = ""
	@Published var errorMessage = ""
	var chatUser: ChatUser?  
	
	

	init(chatUser: ChatUser?){
		self.chatUser = chatUser
		fetchMessages()
	}
	var firestoreListener: ListenerRegistration?
	func fetchMessages(){
		guard let sourceID = FirebaseManager.shared.auth.currentUser?.uid else { return }
		
		guard let destinationID = chatUser?.uid else { return }
		FirebaseManager.shared.firestore
			.collection("messages")
			.document(sourceID)
			.collection(destinationID)
			.order(by: "timestamp")
			.addSnapshotListener { querySnapshot, error in
				if let error = error {
					self.errorMessage = "Mesajları çekme işlemi başarısız oldu \(error)"
					print(error)
					return
				}
				querySnapshot?.documentChanges.forEach({ change in
					if change.type == .added {
						do {
							if let cm = try? change.document.data(as:ChatMessage.self) {
								self.chatMessages.append(cm)
								print("appending")
							}
						}catch{
							print("error")
						}
//						let data = change.document.data()
//						self.chatMessages.append(.init(documentID: change.document.documentID, data: data))
					}
				})
				DispatchQueue.main.async {
					self.count += 1
				}
				
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
			self.recentMessage()
			self.messageText = ""
			self.count += 1
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
	private func recentMessage(){
		guard let chatUser = chatUser else {return}
		
		guard let uid  = FirebaseManager.shared.auth.currentUser?.uid else { return}
		
		guard let destinationID = self.chatUser?.uid else {return}
		
		let document = FirebaseManager.shared.firestore
			.collection("RecentMessage")
			.document(uid)
			.collection("messages")
			.document(destinationID)
		let data = [
			"timestamp" : Timestamp(),
			FirebaseConstants.messageText: self.messageText,
			FirebaseConstants.sourceID: uid,
			FirebaseConstants.destinationID: destinationID,
			FirebaseConstants.email: chatUser.email,
		] as [String : Any]
		document.setData(data) { error in
			if let error = error {
				self.errorMessage = "Failed to save recent messagee \(error)"
				return
			}
		}
	}
	@Published var count = 0
}

struct ChatView: View{
	
//	let chatUser: ChatUser?
//	init(chatUser: ChatUser?){
//		
//		self.chatUser = chatUser
//		self.vm = .init(chatUser: chatUser)
//	}
//	
	@State var messageText = ""
	@ObservedObject var vm: SendButton
	
	var body: some View{
		ZStack {
			messageTopBar
			Text(vm.errorMessage)
		}
		
		.navigationTitle(vm.chatUser?.email ?? "")
		.navigationBarTitleDisplayMode(.inline)
		.onDisappear{
			vm.firestoreListener?.remove()
		}
//		.navigationBarItems(trailing: Button(action: {
//			vm.count += 1
//		}, label: {
//			Text("Count: \(vm.count)")
//		}))
	}
	static let scrollToString = "Empty"
	private var messageTopBar: some View {
		VStack{
			if #available(iOS 15.0, *){
				ScrollView{
					ScrollViewReader{ proxy in
						VStack{
							ForEach(vm.chatMessages) { message in
								MessageViewUI(message:message)
								
							}
							HStack{ Spacer() }
								.id(Self.scrollToString)
						}
						
							.onReceive(vm.$count) { _ in
									withAnimation(.easeOut(duration: 0.5)){
										proxy.scrollTo(Self.scrollToString,anchor: .bottom)
									}
							}
					}
				
					
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
struct MessageViewUI: View {
	let message: ChatMessage
	var body: some View{
		VStack{
			if message.sourceID == FirebaseManager.shared.auth.currentUser?.uid{
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
				
			} else {
				HStack{
					
					HStack{
						Text(message.messageText)
							.foregroundStyle(.black)
					}
					.padding()
					.background(Color.white)
					.cornerRadius(8)
					Spacer ()
					
				}
			}
		}
		.padding(.horizontal)
		.padding(.top, 8)
	}
}
#Preview {
	MessageView()
}
