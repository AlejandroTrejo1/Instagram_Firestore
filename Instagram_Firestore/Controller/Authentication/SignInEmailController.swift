//
//  LoginEmailController.swift
//  Instagram_Firestore
//
//  Created by Alejandro Trejo on 22/07/21.
//

import UIKit




class SignInEmailController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = LoginViewModel()
    
    //Creando un delegado
    weak var authDelegate: AuthenticationDelegate?
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        iv.contentMode = .scaleAspectFill
        return iv
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
    
    private lazy var logginButton: SignCustomButton = {
        let button = SignCustomButton(placeholder: "Iniciar sesion")
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        return button
    }()
    
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(firstPart: "¿Aún no tienes cuenta?", secondPart: "Registrate.")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "¿Olvidaste tu contraseña?", secondPart: "Obten ayuda")
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    // MARK: - Actions
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.authDelegate = authDelegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleShowResetPassword() {
        let controller = ResetPasswordController()
        navigationController?.pushViewController(controller, animated: true)
        controller.email = emailTextField.text
        controller.delegate = self
    }
    
    @objc func handleLogIn() {
        guard  let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        AuthService.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: No se pudo iniciar sesión \(error.localizedDescription)")
                return
            }
            
            self.showLoader(true)
            //Establecemos cuando se activara nuestro delegado
            self.authDelegate?.authenticationDidComplete()
        }
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        configureGradientLayer()
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField,
                                                   logginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
}

// MARK: -FormViewModel
extension SignInEmailController: FormViewModel {
    func updateForm() {
        logginButton.backgroundColor = viewModel.buttonBackgroundColor
        logginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        logginButton.isEnabled = viewModel.formIsValid
    }
}

// MARK: - ResetPasswordControllerDelegate
extension SignInEmailController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Exitoso", message: "Se ha enviado un correo a tu email.")
    }
}
