//
//  UserService.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 15/06/21.
//

import Firebase

typealias FirestoreCompletion = (Error?) -> Void

struct UserService {
    //Cuando se termine de ejecutar, regresara User 
    static func fetchUser(with uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        //Poniendo ruta, tomando documentos de esa ruta y almacenandolos en snapshot
        COLLECTION_USERS.getDocuments { snapshot, error in
            //Unwraping snapshot
            guard let snapshot = snapshot else { return }
            //por cada documento en la query imprimimos sus datos
            snapshot.documents.forEach{ document in
                print("DEBUG: Document in service file. \(document.data())")
                let user = User(dictionary: document.data())
                users.append(user)
            }
            //Cuando terminemos de hacer la consulta, completamos la funcion y regresamos users
            completion(users)
            
            //            let users = snapshot.documents.map({User(dictionary: $0.data()) })
            //            completion(users)
        }
    }
    
    static func follow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        //Ir a la coleccion de la persona que esta logeada y escribir la persona del perfil que se esta visualizando.
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            //Ir a collecion de la persona que se quiere seguir y escribir el uid de nuestro usuario logeado.
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData([:], completion: completion)
        }
    }
    
    static func unfollow(uid: String, completion: @escaping(FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            let followers = snapshot?.documents.count ?? 0
            
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, _ in
                let following = snapshot?.documents.count ?? 0
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, error in
                    let posts = snapshot?.documents.count ?? 0
                    completion(UserStats(followers: followers, following: following, posts: posts))
                }
                
                
            }
        }
    }
    
}
