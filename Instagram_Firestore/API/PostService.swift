//
//  PostService.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 24/06/21.
//

import UIKit
import Firebase

struct PostService {
    static func uploadPost(caption: String, image: UIImage, user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption,
                        "timestamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerUid": uid,
                        "ownerImageUrl": user.profileImageUrl,
                        "ownerUsername": user.username] as [String: Any]
            
            let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
            
            updateUserFeedAfterPost(postId: docRef.documentID)
        }
        
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data())})
            completion(posts)
        }
    }
    
    static func fetchPost(withPostId postId: String, completion: @escaping(Post) -> Void) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            guard let data = snapshot.data() else { return }
            let post = Post(postId: snapshot.documentID, dictionary: data)
            completion(post)
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { snapshot, error in
            
            guard let documents = snapshot?.documents else { return }
            
            print("DEBUG: Documents \(documents)")
            
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data())})
            
            posts.sort(by: {$0.timeStamp.seconds > $1.timeStamp.seconds})
            
            completion(posts)
        }
    }
    
    static func fetchPostLikes(forPostId postId: String, completion: @escaping([User]) -> Void) {
        COLLECTION_POSTS.document(postId).collection("post-likes").getDocuments { snapshot, error in
            var users = [User]()
            guard let snapshot = snapshot else { return }
            snapshot.documents.forEach{ document in
                let user = User(dictionary: document.data())
                users.append(user)
                completion(users)
            }
        }
    }
    
    static func likePost(for post: Post, user: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = ["fullname": user.fullname,
                                   "profileImageUrl": user.profileImageUrl,
                                   "uid": uid,
                                   "username": user.username,
                                   "email": user.email]
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
        
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData(data) { _ in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(for post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
        
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { _ in
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(currentUid).collection("user-likes").document(post.postId).getDocument { snapshot, error in
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
    }
    
    static func fetchFeedPost(completion: @escaping([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var posts = [Post]()
        COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, _ in
            snapshot?.documents.forEach({ document in
                fetchPost(withPostId: document.documentID) { post in
                    posts.append(post)
                    
                    posts.sort(by: {$0.timeStamp.seconds > $1.timeStamp.seconds})
                    
                    completion(posts)
                }
            })
        }
    }
    
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let docIDs = documents.map({ $0.documentID })
            
            docIDs.forEach { id in
                if didFollow {
                    COLLECTION_USERS.document(uid).collection("user-feed").document(id).setData([:])
                } else {
                    COLLECTION_USERS.document(uid).collection("user-feed").document(id).delete()
                }
            }
        }
    }
    
    private static func updateUserFeedAfterPost(postId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-feed").document(postId).setData([:])
            }
            
            COLLECTION_USERS.document(uid).collection("user-feed").document(postId).setData([:])
        }
    }
    
}
