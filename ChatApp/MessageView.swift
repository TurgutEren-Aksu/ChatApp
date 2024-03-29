//
//  MessageView.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 27.11.2023.
// It's my birthday 🥳

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class MainMessageViewModel: ObservableObject{
	
	@Published var errorMessage = ""
	@Published var chatUser: ChatUser?
	@Published var isUserCurrentlyLoggedIn = false
	
	
	init(){
		DispatchQueue.main.async {
			self.isUserCurrentlyLoggedIn =
			FirebaseManager.shared.auth.currentUser?.uid == nil
		}
		
		fetchCurrentUser()
		recentMessage()
	}
	@Published var recentMessaeg = [RecentMessage]()
	
	private var firebaseListener: ListenerRegistration?
	
	func recentMessage(){
		guard let uid  = FirebaseManager.shared.auth.currentUser?.uid else { return }
		
		firebaseListener?.remove()
		self.recentMessaeg.removeAll()
		
		FirebaseManager.shared.firestore
			.collection("RecentMessage")
			.document(uid)
			.collection("messages")
			.order(by: "timestamp")
			.addSnapshotListener { QuerySnapshot, error in
				if let error = error {
					self.errorMessage = "Failed message to listen \(error)"
					return
				}
				QuerySnapshot?.documentChanges.forEach({ changes in
					
						let docID = changes.document.documentID
					if let index = self.recentMessaeg.firstIndex(where: { rm in
						return rm.id == docID
					}){
						self.recentMessaeg.remove(at: index)
					}
					
					do{
						if let rm = try changes.document.data(as: RecentMessage?.self){
							self.recentMessaeg.insert(rm, at: 0)
						}
						
					}
					catch{
						print(error)
					}
					
				})
			}
	}
	func fetchCurrentUser(){
		guard let uid = FirebaseManager.shared.auth.currentUser?.uid
		else {
			self.errorMessage = "Could not find firebase uid"
			return
		}
		self.errorMessage = "\(uid)"
		FirebaseManager.shared.firestore.collection("collectionName")
			.document(uid).getDocument { snapshot, error in
				if let error = error{
					self.errorMessage = "Failed to fetch current user \(error)"
					print("Failed to fetch user:",error)
					return
				}
				guard let data = snapshot?.data() else {
					self.errorMessage = "No data found."
					return
				}
				
				self.chatUser = .init(data: data)
				
				
			}
		
	}
	
	func handleSignOut() {
		isUserCurrentlyLoggedIn.toggle()
		try? FirebaseManager.shared.auth.signOut()
	}
}
struct MessageView: View {
	@ObservedObject var mv = MainMessageViewModel()
	@State var shouldNavigateToChatLogView = false
	@State var options = false
	@State var shouldNewMessageButton = false
	var chatLogViewModel = SendButton(chatUser: nil)
	private var customNavBar: some View {
		HStack(spacing: 16){
			Image(systemName:"person.fill")
				.font(.system(size:34, weight: .heavy))
			VStack(alignment: .leading, spacing: 4){
				Text("\(mv.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")")
					.font(.system(size:24,weight: .bold))
				HStack{
					Circle()
						.foregroundColor(.green)
						.frame(width: 14, height: 14)
					Text("online")
						.font(.system(size: 12))
						.foregroundColor(Color(.lightGray))
				}
			}
			Spacer()
			Button(action: {
				options.toggle()
			}, label: {
				Image(systemName: "gear")
					.font(.system(size: 24, weight: .bold))
					.foregroundColor(Color(.label))
			})
		}
		.padding()
		.actionSheet(isPresented: $options){
			.init(title: Text("Settings"), message:
					Text("What do you wnat to do ?"),
				  buttons: [
					.destructive(Text("Sign Out"), action: {
						print("handle sign out ")
						mv.handleSignOut()
					}),
					.cancel()
					
				  ])
		}
		.fullScreenCover(isPresented: $mv.isUserCurrentlyLoggedIn, onDismiss: nil) {
			ContentView(didComplereLoginProcess: {
				self.mv.isUserCurrentlyLoggedIn = false
				self.mv.fetchCurrentUser()
			})
		}
	}
	
	var body: some View {
		NavigationView{
			VStack{
				customNavBar
				messageView
				NavigationLink("", isActive: 
								$shouldNavigateToChatLogView){
//					ChatView(chatUser: self.chatUser)
					ChatView(vm: chatLogViewModel)
				}
				
				
			}
			.overlay(
				newMessageButton, alignment: .bottom)
			.navigationBarHidden(true)
			.navigationBarBackButtonHidden()
		}
	}
	private var messageView: some View{
		ScrollView{
			ForEach(mv.recentMessaeg) { recentMessaeg in
				VStack{
					Button {
						let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessaeg.sourceID ? recentMessaeg.destinationID : recentMessaeg.sourceID
						self.chatUser = .init(data: [FirebaseConstants.email: recentMessaeg.email,FirebaseConstants.uid: uid])
						self.chatLogViewModel.chatUser = self.chatUser
						self.chatLogViewModel.fetchMessages()
						self.shouldNavigateToChatLogView.toggle()
					} label: {
						HStack{
							Image(systemName: "person.fill")
								.font(.system(size: 32))
								.padding(8)
								.overlay(RoundedRectangle(cornerRadius: 44)
									.stroke(Color(.label), lineWidth:1))
							VStack(alignment: .leading){
								Text(recentMessaeg.email)
									.font(.system(size: 16, weight: .bold))
									.foregroundColor(Color(.label))
									.multilineTextAlignment(.leading)
								Text(recentMessaeg.messageText)
									.font(.system(size:14))
									.foregroundColor(Color(.lightGray))
									.multilineTextAlignment(.leading)
							}
							Spacer()
							Text(recentMessaeg.timeago)
								.font(.system(size: 14, weight: .semibold))
						}
					}
					
					Divider()
						.padding(.vertical, 8)
				}.padding(.horizontal)
			}.padding(.bottom)
		}
	}
	private var newMessageButton: some View {
		Button{
			shouldNewMessageButton.toggle()
		} label: {
			HStack{
				Spacer()
				Text("+ New Message").font(.system(size: 16, weight: .bold))
				Spacer()
			}
			.foregroundColor(Color.white)
			.padding(.vertical)
			.background(Color.blue)
			.cornerRadius(32)
			.padding(.horizontal)
			.shadow(radius: 15)
		}
		.fullScreenCover(isPresented: $shouldNewMessageButton) {
			CreatChat(newChat: { user in
				print(user.email)
				self.shouldNavigateToChatLogView.toggle()
				self.chatUser = user
				self.chatLogViewModel.chatUser = user
				self.chatLogViewModel.fetchMessages()
			})
		}
	}
	@State var chatUser: ChatUser?
}


struct MessageView_Previews: PreviewProvider {
	static var previews: some View{
		MessageView()
			.preferredColorScheme(.dark)
		MessageView()
	}
}
