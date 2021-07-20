//
//  SearchController.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 06/06/21.
//

import UIKit

private let cellIdentifier = "ProfileCell"

class SearchController: UIViewController {

    
    private let reuseIdentifier = "UserCell"
    private let caller: String
    private var post: Post?
    
    init(caller: String, post: Post?) {
        self.caller = caller
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    private let tableView = UITableView()
    private var users = [User]()
    private var filteredUsers = [User]()
    private var posts = [Post]()
    private let  searchController = UISearchController(searchResultsController: nil)
    
    //Se activa si se busca y se escribe algo en SearchBar
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        cv.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
        return cv
    }()
    
    // MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureUI()
        fetchUsersOrLikes()
        fetchPosts()
    }
    
    // MARK: - API
    
    func fetchUsers() {
        UserService.fetchUsers { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    func fetchPosts() {
        PostService.fetchPosts { posts in
            self.posts = posts
            self.collectionView.reloadData()
        }
    }
    
    func fetchLikes() {
        guard let post = post else { return }
        PostService.fetchPostLikes(forPostId: post.postId) { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Explorar"
        //Configurando la cell para que el tableview la pueda usar
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 64
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        tableView.isHidden = true
        
        view.addSubview(collectionView)
        collectionView.fillSuperview()
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar usuario"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
    func fetchUsersOrLikes() {
        if caller == "likes" {
            fetchLikes()
        } else if caller == "search" {
            fetchUsers()
        }
    }
    
}

// MARK: UItableViewDataSource
extension SearchController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserCellViewModel(user: user)
        return cell
        
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
}

// MARK - UITableViewDellegate

extension SearchController: UITableViewDelegate {
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DEBUG: User is \(users[indexPath.row].username)")
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        collectionView.isHidden = true
        tableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        collectionView.isHidden = false
        tableView.isHidden = true
    }
}

// MARK: - UISearchResultsUpdating
//Se invoca Cada que el usuario escriba en el searchBar.
extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("DEBUG: Update user list here")
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({ $0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText) })
        print("DEBUG: Filtered users \(filteredUsers)")
        self.tableView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate

extension SearchController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension SearchController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //Asignando separacion de un pixel a las imagenes en collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //Asigando dimensiones a imagenes en collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
}
