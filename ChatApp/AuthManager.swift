//
//  AuthManager.swift
//  ChatApp
//
//  Created by Turgut Eren Aksu on 10.11.2023.
//

// FirebaseManager.swift

import Firebase

class FirebaseManager: ObservableObject {
	static let shared = FirebaseManager()/*FirebaseManager()*/

	private init() {
		FirebaseApp.configure()
	}

	func loginUser(email: String, password: String, completion: @escaping (String) -> Void) {
		Auth.auth().signIn(withEmail: email, password: password) { result, error in
			if let error = error {
				print("Giriş işlemi başarısız ", error)
				completion("Giriş işlemi Başarısız \(error)")
				return
			}
			print("Giriş işlemi başarılı \(result?.user.uid ?? "")")
			completion("Giriş işlemi başarılı \(result?.user.uid ?? "")")
		}
	}

	func newAccount(email: String, password: String, completion: @escaping (String) -> Void) {
		Auth.auth().createUser(withEmail: email, password: password) { result, error in
			if let error = error {
				print("Kullanıcı oluşturma başarısız ", error)
				completion("Kullanıcı Oluşturma Başarısız \(error)")
				return
			}
			print("Kullanıcı oluşturma başarılı \(result?.user.uid ?? "")")
			completion("Kullanıcı oluşturma başarılı \(result?.user.uid ?? "")")
		}
	}
}
