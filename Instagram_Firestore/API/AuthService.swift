//
//  AuthService.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 14/06/21.
//

import UIKit
import Firebase


struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUsers(withCredentials credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        //Una vez que la imagen se subio podemos acceder a imageURL in
        ImageUploader.uploadImage(image: credentials.profileImage) { imageURL in
            //Accedemos a ImageURL
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                if let error = error {
                    print("DEBUG: Hubo un error registrando al usuario: \(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = ["email": credentials.email,
                                           "fullname": credentials.fullname,
                                           "profileImageUrl": imageURL,
                                           "uid": uid,
                                           "username": credentials.username]
                //creamos Users y dentro de el creamos un documento por cada usuario para despues escribir sobre ese documento
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
                
            }
        }
    }
    
    static func resetPassword(with email: String, completion: SendPasswordResetCallback?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
}
