//
//  UserCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 16/06/21.
//

import UIKit

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    
    //Declaramos el ViewModel que contiene todos los datos listos para la celda
    var viewModel: UserCellViewModel? {
        didSet {
            configure()
        }
    }
    
//    var user: User? {
//        didSet{
//            userNameLabel.text = user?.username
//            fullNameLabel.text = user?.fullname
//            profileImageView.sd_setImage(with: URL(string: user!.profileImageUrl))
//        }
//    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = #imageLiteral(resourceName: "venom-7")
        return iv
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Jhano"
        return label
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Alejandro"
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        let stack = UIStackView(arrangedSubviews: [userNameLabel, fullNameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: -Helpers
    //Asignamos los valores del viewmodel a los elementos de UI
    func configure() {
        guard let viewModel = viewModel else { return }
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        userNameLabel.text = viewModel.userName
        fullNameLabel.text = viewModel.fullname
        
    }
    
}
