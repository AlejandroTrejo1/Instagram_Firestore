//
//  RegistrationController.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 07/06/21.
//

import UIKit
import GoogleSignIn

class RegistrationController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = RegistrationViewModel()
    private var profileImage: UIImage?
    weak var authDelegate: AuthenticationDelegate?
    
    private let plushPhotoBotton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
        return button
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextfield(placeholder: "Correo", firstletterCapitalized: false)
        tf.keyboardType = .emailAddress
        
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextfield(placeholder: "Contraseña", firstletterCapitalized: false)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let fullNameTextField: UITextField = CustomTextfield(placeholder: "Nombre completo", firstletterCapitalized: true)
    private let usernameTextField: UITextField = CustomTextfield(placeholder: "Usuario", firstletterCapitalized: false)
    
    private lazy var signUpButton: UIButton = {
        let button = SignCustomButton(placeholder: "Registrarse")
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    
    
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(firstPart: "¿Ya tienes cuenta?", secondPart: "Inicia Sesión.")
        button.addTarget(self, action: #selector(handleShowLogIn), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: -Actions
    @objc func handleShowLogIn(){
        let controller = SignInController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == fullNameTextField {
            viewModel.fullName = sender.text
        } else if sender == usernameTextField {
            viewModel.username = sender.text
        }
        
        updateForm()
        
        
    }
    
    @objc func handleProfilePhotoSelect() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text?.lowercased() else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullNameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let profileImage = self.profileImage else { return }
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        AuthService.registerUsers(withCredentials: credentials) { error in
            if let error = error {
                print("DEBUG: Hubo un error registrando al usuario: \(error.localizedDescription)")
                return
            }
            
            self.authDelegate?.authenticationDidComplete()
            
            
        }
    }
    
    // MARK: -Helpers
    func configureUI() {
        configureGradientLayer()
        
        view.addSubview(plushPhotoBotton)
        plushPhotoBotton.centerX(inView: view)
        plushPhotoBotton.setDimensions(height: 140, width: 140)
        plushPhotoBotton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField,
                                                   fullNameTextField, usernameTextField, signUpButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: plushPhotoBotton.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
        
        
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
    }
    
}

// MARK: -FormViewModel

extension RegistrationController: FormViewModel {
    func updateForm() {
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
    }
}


// MARK: -UIImagePickerControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        profileImage = selectedImage
        
        plushPhotoBotton.layer.cornerRadius = plushPhotoBotton.frame.width / 2
        plushPhotoBotton.layer.masksToBounds = true
        plushPhotoBotton.layer.borderColor = UIColor.white.cgColor
        plushPhotoBotton.layer.borderWidth = 2
        plushPhotoBotton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
}
