//
//  SignCustomButton.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 08/06/21.
//

import UIKit

class SignCustomButton: UIButton {
    init(placeholder: String) {
        super.init(frame: .zero)
        setTitle(placeholder, for: .normal)
        setTitleColor(UIColor(white: 1, alpha: 0.67), for: .normal)
        backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
        layer.cornerRadius = 5
        setHeight(50)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
