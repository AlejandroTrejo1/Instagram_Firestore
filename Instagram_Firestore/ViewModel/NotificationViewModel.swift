//
//  NotificationViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 08/07/21.
//

import UIKit

struct NotificationViewModel {
    var notification: Notification
    init(notification: Notification) {
        self.notification = notification
    }
    
    var postImageUrl: URL? {
        return URL(string: notification.postImageUrl ?? "")
    }
    
    var profileImageUrl: URL? {
        return URL(string: notification.userProfileImageUrl)
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: notification.timestamp.dateValue(), to: Date()) 
    }
    
    var notificationMessage: NSAttributedString {
        let username = notification.username
        let message = notification.type.notificationMessage
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: message, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: " \(timestampString ?? "2m")", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
    var shouldHidePostImage: Bool {
        return self.notification.type == .follow
    }
    
    var followButtonText: String {
        return notification.userIsFollowed ? "Siguiendo" : "Seguir"
    }
    
    var followButtonBackGroundColor: UIColor {
        return notification.userIsFollowed ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return notification.userIsFollowed ? .black : .white
    }
    
}
