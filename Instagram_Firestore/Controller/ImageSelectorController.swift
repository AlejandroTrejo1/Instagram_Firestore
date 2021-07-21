//
//  ImageSelectorController.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 06/06/21.
//

import UIKit
import YPImagePicker
import Firebase

class ImageSelectorController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        configure()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configure()
    }
    
    var mainTabController: MainTabController
    
    init(maintab: MainTabController) {
        self.mainTabController = maintab
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Properties
        
    var user: User?
        
    var imagePicker = UIImagePickerController()
    
    // MARK: - Helpers
    
    func configure() {
        fetchCurrentUser()

        let alertController = UIAlertController(title: "Seleccionar Foto", message: "Elige una opción.", preferredStyle: .alert)
        
        // Create the actions
        let takePhoto = UIAlertAction(title: "Tomar fotografia.", style: .default, handler: { action in
            self.openCamera()
        })
        let chooseFromGallery = UIAlertAction(title: "Elegir de biblioteca.", style: .default) { action in
            self.openLibrary()
        }
        
        let cancell = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            self.hideController(handleRefresh: false)
        }
        
        // Add the actions
        alertController.addAction(takePhoto)
        alertController.addAction(chooseFromGallery)
        alertController.addAction(cancell)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hideController(handleRefresh: Bool) {
        let referenceToMainTab = self.mainTabController as UITabBarController
        referenceToMainTab.selectedIndex = 0
        
        guard let feedNav = referenceToMainTab.viewControllers?.first as? UINavigationController else { return }
        guard let feed = feedNav.viewControllers.first as? FeedController else { return }
        if handleRefresh {
            feed.handleRefresh()
            
        }
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
    
    
    
    
    
    
    // MARK: - API
    func fetchCurrentUser() {
        UserService.getCurrentUser { user in
            self.user = user
        }
    }
    
    // MARK: - Actions
    
    func openCamera()
    {
        var config = YPImagePickerConfiguration()
        config.shouldSaveNewPicturesToAlbum = true
        config.wordings.cameraTitle = "Foto"
        config.wordings.cancel = "Cancelar"
        config.wordings.next = "Seleccionar"
        config.wordings.filter = "Filtros"
        config.wordings.libraryTitle = "Libreria"
        let picker = YPImagePicker(configuration: config)
        picker.dismiss(animated: true) {
            self.hideController(handleRefresh: false)
        }
        present(picker, animated: true, completion: nil)
        didFinishedPickingMedia(picker)
    }
    
    func openLibrary() {
        print("DEBUG: Open library")
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = .library
        config.screens = [.library]
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.wordings.cancel = "Cancelar"
        config.wordings.next = "Seleccionar"
        config.wordings.filter = "Filtros"
        config.wordings.libraryTitle = "Libreria"
        config.library.maxNumberOfItems = 1
        
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        picker.dismiss(animated: true) {
            self.hideController(handleRefresh: false)
        }
        present(picker, animated: true, completion: nil)
        
        didFinishedPickingMedia(picker)
    }
    
}

extension ImageSelectorController: UploadPostControllerDelegate {
    func controllerDidFinishedUploadingPost(_ controller: UploadPostController) {
        controller.dismiss(animated: true, completion: nil)
        hideController(handleRefresh: true)
        
    }
    
    
}

