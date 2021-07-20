//
//  MainTabController.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 05/06/21.
//

import UIKit
import Firebase
import YPImagePicker

class MainTabController: UITabBarController {
    
    // MARK: - Lifecycle
    
    //Configuramos el viewController hasta que user este listo
    var user: User? {
        didSet {
            //nos aseguramos que el user si exista
            guard let user = user else { return }
            configureViewControllers(withUser: user)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        fetchUser()
    }
    
    // MARK: - API
    //Traemos el usuario desde fireBase
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(with: uid)  { user in
            //guardamos el usuario de firebase en self.user
            self.user = user
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = LoginController()
                //Le decimos a LoginController que su delegado sera este Controlador
                controller.authDelegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            
        }
    }
    
    // MARK: - Helpers
    
    func configureViewControllers(withUser user: User) {
        view.backgroundColor = .white
        
        self.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        
        let feed = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedController(collectionViewLayout: layout))
        
        let search = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchController(caller: "search", post: nil))
        
        let imageSelector = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: ImageSelectorController())
        
        let notifications = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsCotroller())
        
        //mandamos el usuario a ProfileCoontroller
        let profileController = ProfileController(user: user)
        let profile = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: profileController)
        
        //Esta propiedad proviene de UITabBarController
        viewControllers = [feed, search, imageSelector, notifications, profile]
        
        tabBar.tintColor = .black
    }
    
    func templateNavigationViewContoller(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.navigationBar.tintColor = .black
        return nav
    }
    
    func didFinishedPickingMedia(_ picker: YPImagePicker) {
        picker.didFinishPicking { items, _ in
            picker.dismiss(animated: false) {
                guard let selectedImage = items.singlePhoto?.image else { return }
                //Presentar UploadPostController
                let controller = UploadPostController()
                controller.selectedImage = selectedImage
                controller.uploadDelegate = self
                controller.currentUser = self.user
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        }
    }
    
}


// MARK: - AuthenticationDelegate
//Funcion del delegado. Esta funcion se llama por el Delegador (LoginController) en la linea 100
extension MainTabController: AuthenticationDelegate {
    func authenticationDidComplete() {
        print("DEBUG: Auth did complete. fetch user ")
        //traemos el usuario de Firebase
        fetchUser()
        //Ocultamos el controlador
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK - UITabBarControllerDelegate


extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        print("DEBUG: Index of view Controller is \(index)")
        
        if index == 2 {
            var config = YPImagePickerConfiguration()
            config.library.mediaType = .photo
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.screens = [.library]
            config.hidesStatusBar = false
            config.hidesBottomBar = false
            config.library.maxNumberOfItems = 1
            
            let picker = YPImagePicker(configuration: config)
            picker.modalPresentationStyle = .fullScreen
            present(picker, animated: true, completion: nil)
            
            didFinishedPickingMedia(picker)
        }
        
        return true
    }
}

// MARK: - UploadPostControllerDelegate

extension MainTabController: UploadPostControllerDelegate {
    func controllerDidFinishedUploadingPost(_ controller: UploadPostController) {
        selectedIndex = 0
        controller.dismiss(animated: true, completion: nil)
        
        guard let feedNav = viewControllers?.first as? UINavigationController else { return }
        guard let feed = feedNav.viewControllers.first as? FeedController else { return }
        feed.handleRefresh()
    }
}
