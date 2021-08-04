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
        
//        let firebaseAuth = Auth.auth()
//    do {
//      try firebaseAuth.signOut()
//    } catch let signOutError as NSError {
//      print("Error signing out: %@", signOutError)
//    }
      
        
        fetchUser()
//        let controller = ImageSelectorController()
//        controller.selectorDelegate = self
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
                let controller = SignInController()
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
        
        let layout = UICollectionViewFlowLayout()
        
        let feed = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedController(collectionViewLayout: layout))
        
        let search = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchController(caller: "search", post: nil))
        
        let imageSelector = templateNavigationViewContoller(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: ImageSelectorController(maintab: self))
        
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

    

