//
//  FeedCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 06/06/21.
//

import UIKit

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell: FeedCell, WantsToShowCommentsfor post: Post)
    func cell(_ cell: FeedCell, didLike post: Post)
    func cell(_ cell: FeedCell, wantsToShowLikesFor post: Post)
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String)
}

class FeedCell: UICollectionViewCell {
    
    // MARK: Properties
    
    var viewModel: PostViewModel? {
        didSet { configure() }
    }
    
    weak var cellDelegate: FeedCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(didTapUsername), for: .touchUpInside)
        return button
    }()
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.image = #imageLiteral(resourceName: "venom-7")
        return iv
    }()
    
        lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapComments), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private lazy var likesBtn: UIButton = {
       let btn = UIButton()
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btn.addTarget(self, action: #selector(showLikes), for: .touchUpInside)
        return btn
    }()
    
    private let captionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let postTimeLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(usernameButton)
        usernameButton.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8)
        
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureActionButtons()
        
        addSubview(likesBtn)
        likesBtn.anchor(top: likeButton.bottomAnchor, left: leftAnchor, paddingTop: -4, paddingLeft: 8)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesBtn.bottomAnchor, left: leftAnchor, paddingTop: 1, paddingLeft: 8)
        
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -Actions

    @objc func didTapUsername() {
        guard let viewmodel = viewModel else { return }
        cellDelegate?.cell(self, wantsToShowProfileFor: viewmodel.post.ownerUid)
    }
    
    @objc func didTapLike() {
        guard let viewmodel = viewModel else { return }
        cellDelegate?.cell(self, didLike: viewmodel.post)
    }
    
    @objc func didTapComments() {
        guard let viewModel = viewModel else { return }
        cellDelegate?.cell(self, WantsToShowCommentsfor: viewModel.post)
    }
    
    @objc func showLikes() {
        guard let viewmodel = viewModel else { return }
        cellDelegate?.cell(self, wantsToShowLikesFor: viewmodel.post)
    }
    
    
    // MARK: -Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        captionLabel.text = viewModel.caption
        postImageView.sd_setImage(with: viewModel.imageUrl)
        
        profileImageView.sd_setImage(with: viewModel.userProfileImageUrl)
        usernameButton.setTitle(viewModel.username, for: .normal)
        
        likesBtn.setTitle(viewModel.likesLabelText, for: .normal)
        likesBtn.setTitleColor(.black, for: .normal)
        
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        postTimeLabel.text = viewModel.timestampString
    }
    
    func configureActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, width: 120, height: 50)
    }
}
