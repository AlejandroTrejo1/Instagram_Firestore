//
//  ImageSelectorController.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 06/06/21.
//

import UIKit
import YPImagePicker
import Firebase
import PhotosUI

class ImageSelectorController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    var imagePicked: UIImage?
    
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
    
    func didFinishedPickingMedia() {
        
        //Presentar UploadPostController
        let controller = UploadPostController()
        controller.selectedImage = imagePicked
        controller.uploadDelegate = self
        controller.currentUser = self.user
        
        
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: false, completion: nil)
    }
    
    
    
    
    
    
    
    // MARK: - API
    func fetchCurrentUser() {
        UserService.getCurrentUser { user in
            self.user = user
        }
    }
    
    // MARK: - Actions
    
    func openCamera() {
        print("DEBUG: Open Camera")
    }
    
    func openLibrary() {
        print("DEBUG: Open library")

        var config = PHPickerConfiguration()
        config.filter = .images
        
        
        let picker = PHPickerViewController(configuration: config)
        picker.dismiss(animated: true) {
            print("Dismissed")
            self.hideController(handleRefresh: false)
        }
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    
}

extension ImageSelectorController: UploadPostControllerDelegate {
    func controllerDidFinishedUploadingPost(_ controller: UploadPostController) {
        controller.dismiss(animated: true, completion: nil)
        hideController(handleRefresh: true)
        
    }
    
    
}

extension ImageSelectorController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage else { return }
                    self.imagePicked = image
                    self.didFinishedPickingMedia()
                    
                }
            }
        }
        
    }
}
