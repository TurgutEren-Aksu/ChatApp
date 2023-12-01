//
//  MessageView.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 27.11.2023.
//

import SwiftUI
class MainMessageViewModel: ObservableObject{
	
	@Published var errorMessage = ""
	
	init(){
		fetchCurrentUser()
	}
	private func fetchCurrentUser(){
		
		guard let uid =
		FirebaseManager.shared.auth.currentUser?.uid else {return}
		
		self.errorMessage = "\(uid)"
		
		FirebaseManager.shared.firestore.collection("users")
			.document(uid).getDocument{ snapshot, error in
				if let error = error{
					print("Failed to fetch user:",error)
					return
				}
				guard let data = snapshot?.data() else {return}
				print(data)
			}
	}
}
struct MessageView: View {
	@ObservedObject var mv = MainMessageViewModel()
	@State var options = false
	private var customNavBar: some View {
		HStack(spacing: 16){
			Image(systemName:"person.fill")
				.font(.system(size:34, weight: .heavy))
			VStack(alignment: .leading, spacing: 4){
				Text("USERNAME")
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
					}),
					.cancel()
					
				  ])
		}
	}
	
	var body: some View {
		NavigationView{
			VStack{
				Text("Current User ID:\(mv.errorMessage)")
				customNavBar
				messageView
			}
			.overlay(
				newMessageButton, alignment: .bottom)
			.navigationBarHidden(true)
			.navigationBarBackButtonHidden()
		}
	}
	private var messageView: some View{
		ScrollView{
			ForEach(0..<10, id: \.self) { num in
				VStack{
					HStack{
						Image(systemName: "person.fill")
							.font(.system(size: 32))
							.padding(8)
							.overlay(RoundedRectangle(cornerRadius: 44)
								.stroke(Color(.label), lineWidth:1))
						VStack(alignment: .leading){
							Text("Username")
								.font(.system(size: 16, weight: .bold))
							Text("Message sent to user")
								.font(.system(size:14))
								.foregroundColor(Color(.lightGray))
						}
						Spacer()
						Text("22d")
							.font(.system(size: 14, weight: .semibold))
					}
					Divider()
						.padding(.vertical, 8)
				}.padding(.horizontal)
			}.padding(.bottom, 50)
		}
	}
	private var newMessageButton: some View {
		Button{
			
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
	}
}

struct MessageView_Previews: PreviewProvider {
	static var previews: some View{
		MessageView()
			.preferredColorScheme(.dark)
		MessageView()
	}
}
