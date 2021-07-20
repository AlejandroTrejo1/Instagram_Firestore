//
//  Post.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 26/06/21.
//

import Foundation
import Firebase

struct Post {
    var caption: String
    var likes: Int
    let imageUrl: String
    let ownerUid: String
    let timeStamp: Timestamp
    let postId: String
    let ownerImageUrl: String
    let ownerUsername: String
    var didLike = false
    
    init(postId: String, dictionary: [String: Any]) {
        self.postId = postId
        self.caption = dictionary["caption"] as? String ?? ""
        self .likes = dictionary["likes"] as? Int ?? 0
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        self.ownerUsername = dictionary["ownerUsername"] as? String ?? ""
        self.timeStamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
    
}
