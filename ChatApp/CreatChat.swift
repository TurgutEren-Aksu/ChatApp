//
//  CreatChat.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 5.12.2023.
//

import SwiftUI

struct CreatChat: View {
	
	@Environment(\.presentationMode) var presentationMode
	
    var body: some View {
		NavigationView{
			ScrollView{
				ForEach(0..<10) { num in
					Text("New User")
					
				}
			}.navigationTitle("New Message")
				.toolbar {
					ToolbarItemGroup(placement: .topBarLeading) {
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
