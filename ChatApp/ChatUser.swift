//
//  ChatUser.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 5.12.2023.
//

import Foundation

struct ChatUser {
	let uid,email:String
	
	init(data: [String: Any]){
		self.uid = data["uid"] as? String ?? ""
		self.email = data["email"] as? String ?? ""
	}
}
