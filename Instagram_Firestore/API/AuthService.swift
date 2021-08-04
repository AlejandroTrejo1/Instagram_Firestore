//
//  AuthService.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 14/06/21.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import FirebaseMessaging


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
    
    static func signInWithThirdProvider(withCredential credential: AuthCredential, completion: @escaping(Error?, Bool) -> Void) {
        
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("Error Registrando con google \(error.localizedDescription)")
                return
            }
            
            guard let isNewUser = result?.additionalUserInfo?.isNewUser else { return }
            print("es nuevo usuario: \(isNewUser)")
            completion(error, isNewUser)
        }
        
    }
    
    
    static func registerWithoutEmail(completion: @escaping(Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        print("Register without email")
        
        if currentUser.photoURL == nil {
            print("usuario sin imagen")
            let image: UIImage
            image = UIImage(named: "profile_selected")!
            ImageUploader.uploadImage(image: image) { imageUrl in
                let data: [String: Any] = ["email": currentUser.email as Any,
                                           "fullname": currentUser.displayName as Any,
                                           "profileImageUrl": imageUrl as Any,
                                           "uid": currentUser.uid,
                                           "username": currentUser.email as Any]
                
                COLLECTION_USERS.document(currentUser.uid).setData(data, completion: completion)
            }
        } else {
            guard let imageUrl = currentUser.photoURL else { return }
            ImageUploader.downloadImage(from: imageUrl) { data in
                if let image = UIImage(data: data) ?? UIImage(named: "profile_selected") {
                    ImageUploader.uploadImage(image: image) { imageUrl in
                        let data: [String: Any] = ["email": currentUser.email as Any,
                                                   "fullname": currentUser.displayName as Any,
                                                   "profileImageUrl": imageUrl as Any,
                                                   "uid": currentUser.uid,
                                                   "username": currentUser.email as Any]
                        COLLECTION_USERS.document(currentUser.uid).setData(data, completion: completion)
                    }
                }
            }
        }
        
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
    
    //
    
    
    
    static func resetPassword(with email: String, completion: SendPasswordResetCallback?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    
}
