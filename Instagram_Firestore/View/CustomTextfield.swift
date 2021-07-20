//
//  CustomTextfield.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 07/06/21.
//

import UIKit

class  CustomTextfield: UITextField {
    init(placeholder: String, firstletterCapitalized: Bool) {
        super.init(frame: .zero)
        
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        if firstletterCapitalized {
            autocapitalizationType = .sentences
        } else {
            autocapitalizationType = .none
        }
        leftView = spacer
        leftViewMode = .always
        borderStyle = .none
        textColor = .white
        keyboardAppearance = .dark
        keyboardType = .emailAddress
        backgroundColor = UIColor(white: 1, alpha: 0.1)
        setHeight(50)
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.7)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
