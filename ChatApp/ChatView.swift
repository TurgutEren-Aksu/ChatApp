import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View{
	
	let chatUser: ChatUser?
	@State var messageText = ""
	
	var body: some View{
		ZStack{
			messageTopBar
			VStack{
				Spacer()
				chatBottomBar
					.background(Color.white)
			}
			
		}
		
		
		.navigationTitle(chatUser?.email ?? "")
		.navigationBarTitleDisplayMode(.inline)
	}
	private var messageTopBar: some View {
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
		.padding(.bottom,65)
	}
	private var chatBottomBar: some View {
		HStack(spacing: 16){
			TextField("Descripttion", text: $messageText)
			Button {
				
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
