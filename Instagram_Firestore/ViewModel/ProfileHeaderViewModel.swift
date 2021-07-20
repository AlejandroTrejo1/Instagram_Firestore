//
//  ProfileHeaderViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 15/06/21.
//

import UIKit

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var  followButtonText: String {
        if user.isCurrentUser {
            return "Editar Perfil"
        }
        
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isCurrentUser ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return user.isCurrentUser ? .black : .white
    }
    
    var numberOfFollowers: NSAttributedString {
        return attributedStatText(value: user.stats.followers, label: "Followers")
    }
    
    var numbersOfFollowing: NSAttributedString {
        return attributedStatText(value: user.stats.following, label: "Following")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributedStatText(value: user.stats.posts, label: "Posts")
    }
    
    init(user: User){
        self.user = user
    }
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}
