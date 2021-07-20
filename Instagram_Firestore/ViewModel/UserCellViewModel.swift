//
//  UserCellViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 17/06/21.
//

import UIKit

struct UserCellViewModel {
    private let user: User
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var userName: String? {
        return user.username
    }
    
    var fullname: String? {
        return user.fullname
    }
    
    //Numero de usuario
    init(user: User) {
        self.user = user
    }
}
