//
//  CreatChat.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 5.12.2023.
//

import SwiftUI

class CreatNewMessageViewModel: ObservableObject {
	@Published var users = [ChatUser]()
	@Published var errorMessage = ""
	init(){
		fetchAllUser()
	}
	func fetchAllUser(){
		FirebaseManager.shared.firestore.collection("collectionName")
			.getDocuments { documentsSnapshot, error in
				if let error = error {
					self.errorMessage = "Failed to fetch users \(error)"
					print("Failed to fetch users \(error)")
					return
				}
				documentsSnapshot?.documents.forEach({snapshot in
					let data = snapshot.data()
					let user = ChatUser(data: data)
					if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
						self.users.append(.init(data: data))
					}
				})
			}
		
	}
}

struct CreatChat: View {
	
	let newChat: (ChatUser) -> ()
	@Environment(\.presentationMode) var presentationMode
	@ObservedObject var mv  = CreatNewMessageViewModel()
	
    var body: some View {
		NavigationView{
			ScrollView{
				Text(mv.errorMessage)
				
				ForEach(mv.users) { user in
					Button {
						presentationMode.wrappedValue.dismiss()
						newChat(user)
					} label: {
						HStack(spacing: 16){
							Text(user.email)
								.foregroundColor(Color(.label))
							Spacer()
						}.padding(.horizontal)
					}
					Divider()
						.padding(.vertical,8)
				}
				
					
			}.navigationTitle("New Message")
				.toolbar {
					ToolbarItemGroup(placement: .navigationBarLeading) {
						Button{
							presentationMode.wrappedValue.dismiss()
						} label: {
							Text("Cancel")
						}
					}
				}
		}
    }
}

#Preview {
    MessageView()
}
