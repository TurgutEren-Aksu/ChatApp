//
//  FirebaseManager.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 10.11.2023.
//

import Foundation
import Firebase
import Foundation

class FirebaseManager: ObservableObject {
	@Published var loginStatusMessage = ""
	private let auth: Auth
	
	init() {
		FirebaseApp.configure()
		self.auth = Auth.auth()
	}

	func loginUser(email: String, password: String) {
		auth.signIn(withEmail: email, password: password) { result, error in
			if let error = error {
				print("Giriş işlemi başarısız ", error)
				self.loginStatusMessage = "Giriş işlemi Başarısız\(error)"
				return
			}
			print("Giriş işlemi başarılı \(result?.user.uid ?? "")")
			self.loginStatusMessage = "Giriş işlemi başarılı \(result?.user.uid ?? "")"
		}
	}

	func newAccount(email: String, password: String) {
		auth.createUser(withEmail: email, password: password) { result, error in
			if let error = error {
				print("Kullanıcı oluşturma başarısız ", error)
				self.loginStatusMessage = "Kullanıcı Oluşturma Başarısız\(error)"
				return
			}
			print("Kullanıcı oluşturma başarılı \(result?.user.uid ?? "")")
			self.loginStatusMessage = "Kullanıcı oluşturma başarılı \(result?.user.uid ?? "")"
		}
	}
}
