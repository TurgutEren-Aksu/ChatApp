import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
class SendButton: ObservableObject{
	
	@Published var messageText = ""
	@Published var errorMessage = ""
	let chatUser: ChatUser?  
	
	init(chatUser: ChatUser?){
		self.chatUser = chatUser
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
		
		let messageCollection = ["sourceID": sourceID, "destinationID" : destinationID, "text" : self.messageText, "timestamp" : Timestamp() ] as [String : Any]
		document.setData(messageCollection) { error  in
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
					ForEach(0..<30){ num in
						HStack{
							Spacer ()
							HStack{
								Text("FAKE MESSAGE FOR NOW")
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
			TextField("Descripttion", text: $messageText)
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

#Preview {
	NavigationView{
		ChatView(chatUser: .init(data: ["uid" : "REAL USER UID", "email" : "eren3@gmail.com"]))
	}
}
