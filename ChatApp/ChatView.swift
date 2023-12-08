import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct ChatView: View{
	
	let chatUser: ChatUser?
	@State var messageText = ""
	
	var body: some View{
		VStack{
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
			HStack{
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
		
		.navigationTitle(chatUser?.email ?? "")
			.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	NavigationView{
		ChatView(chatUser: .init(data: ["uid" : "REAL USER UID", "email" : "eren3@gmail.com"]))
	}
}
