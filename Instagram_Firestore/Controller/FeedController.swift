//
//  FeedController.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 06/06/21.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedController: UICollectionViewController {
    // MARK: - Lifecycle
    
    private var posts = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    //Esta variable tendra valor solamente si es llamada desde el ProfileController
    //Esto nos ayudara a reusar este controller.
    var post: Post? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var user: User?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        configureUI()
        fetchPosts()
        
        if post != nil {
            checkIfUserLikedPosts()
        }
        
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
        
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if post == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cerrar Sesión",
                                                                style: .plain, target: self,
                                                                action: #selector(handleLogout))
        }
        
        navigationItem.title = "Inicio"
        
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
    
    // MARK: - API
    func fetchPosts() {
        guard post == nil else { return }
        PostService.fetchFeedPost { posts in
            self.posts = posts
            self.checkIfUserLikedPosts()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    
    func checkIfUserLikedPosts() {
        if let post = post {
            PostService.checkIfUserLikedPost(post: post) { didLike in
                self.post?.didLike = didLike
            }
        } else {
            posts.forEach { post in
                PostService.checkIfUserLikedPost(post: post) { didLike in
                    if let index = self.posts.firstIndex(where: { $0.postId == post.postId}) {
                        self.posts[index].didLike = didLike
                    }
                }
            }
        }
    }
    
    // MARK: -Actions
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            let controller = LoginController()
            controller.authDelegate = self.tabBarController as? MainTabController
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("DEBUG: Error al cerrar sesión: \(error)")
        }
    }
    
}




    // MARK: - UICollectionViewDataSource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post == nil ? posts.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.cellDelegate = self
        //Si post no es nulo
        if let post = post {
            cell.viewModel = PostViewModel(post: post)
        } else {
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
        }
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        return CGSize(width: width, height: height)
    }
}

//MARK: - FeedCellDelegate
extension FeedController: FeedCellDelegate {
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(with: uid) { user in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: FeedCell, WantsToShowCommentsfor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        cell.viewModel?.post.didLike.toggle()
        if post.didLike {
            PostService.unlikePost(for: post) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                cell.likeButton.tintColor = .black
                cell.viewModel?.post.likes = post.likes - 1
            }
        } else {
            guard let tab = self.tabBarController as? MainTabController else { return }
            guard let user = tab.user else { return }
            
            PostService.likePost(for: post, user: user) { _ in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                cell.likeButton.tintColor = .red
                cell.viewModel?.post.likes = post.likes + 1
                
                NotificationService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .like, post: post)
            }
        }
    }
    
    func cell(_ cell: FeedCell, wantsToShowLikesFor post: Post) {
        
        print("DEBUG: Post to pass controller \(post.postId)")
        let controller = SearchController(caller: "likes", post: post)
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
}
