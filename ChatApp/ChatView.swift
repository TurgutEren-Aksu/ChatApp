import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
class SendButton: ObservableObject{
	
	@Published var messageText = ""
	
	init(){
		
	}
	func handleSend(){
		print(messageText)
	}
}
struct ChatView: View{
	
	let chatUser: ChatUser?
	@State var messageText = ""
	@ObservedObject var vm = SendButton()
	
	var body: some View{
		messageTopBar
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
