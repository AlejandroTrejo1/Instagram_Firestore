//
//  LoginController.swift
//  InstagramFirestoreTutorial
//
//  Created by Alejandro Trejo on 07/06/21.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices
import CryptoKit
//Establecemos el protocolo en el Delegador
protocol AuthenticationDelegate: AnyObject {
    //lista de comandos para el delegado
    func authenticationDidComplete()
}

class SignInController: UIViewController {
    
    
    // MARK: - Properties
    
    private var viewModel = LoginViewModel()
    
    //Creando un delegado
    weak var authDelegate: AuthenticationDelegate?
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    private lazy var appleSignIn: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(signInApple), for: .touchUpInside)
       
        return button
    }()
    
    private lazy var customAppleButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "SignInApple")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleAppleButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var  googleSignIn: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(signInGoogle), for: .touchUpInside)
        return button
    }()
    
    private lazy var customGoogleButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "SignInGoogle")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleGoogleButton), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var facebookSignIn: FBLoginButton = {
        let button = FBLoginButton()
        button.addTarget(self, action: #selector(signInFacebook), for: .touchUpInside)
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private lazy var customFacebookButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "SignInFacebook")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleFacebookButton), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(firstPart: "¿Aún no tienes cuenta?", secondPart: "Registrate.")
        button.addTarget(self, action: #selector(switchToSignUp), for: .touchUpInside)
        return button
    }()
    
    private let emailSignIn: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "SignInEmail")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(switchToEmailSignIn), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func switchToEmailSignIn() {
        let controller = SignInEmailController()
        controller.authDelegate = authDelegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func switchToSignUp() {
        let controller = SignUpController()
        controller.authDelegate = authDelegate
        self.navigationController?.pushViewController(controller, animated: true)
       
    }
    
    @objc func handleFacebookButton() {
        facebookSignIn.sendActions(for: .touchUpInside)
    }
    
    @objc func handleGoogleButton() {
        googleSignIn.sendActions(for: .touchUpInside)
    }
    
    @objc func handleAppleButton() {
        appleSignIn.sendActions(for: .touchUpInside)
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.authDelegate = authDelegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @objc func signInGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            
            if let error = error {
                print("Error en iniciar sesión: \(error.localizedDescription)")
                return
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            AuthService.signInWithThirdProvider(withCredential: credential) { error, isNewUser in
                if let error = error {
                    print("DEBUG: No se pudo iniciar sesión \(error.localizedDescription)")
                    return
                }
                
                if isNewUser {
                    self.showLoader(true)
                    AuthService.registerWithoutEmail { error in
                        if let error = error {
                            print("DEBUG: Hubo un error registrando al usuario: \(error.localizedDescription)")
                            return
                        }
                        print("Poniendo delegado nuevo usuario")
                        self.showLoader(false)
                        self.authDelegate?.authenticationDidComplete()
                    }
                    return
                }
                print("Poniendo delegado Usuario existente")
                self.authDelegate?.authenticationDidComplete()
            }
            
        }
        
    }
    
    @objc func signInFacebook() {
        facebookSignIn.delegate = self
        
    }
    
    fileprivate var currentNonce: String?
    
    @available(iOS 13, *)
    @objc func signInApple() {
        let nonce = GenerateNonce.randomNonceString()
         currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        request.nonce = GenerateNonce.sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    
    
    @objc func signInEmail() {
        let controller = SignInEmailController()
        navigationController?.pushViewController(controller, animated: true)
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
        
        let stackButtons = UIStackView(arrangedSubviews: [customAppleButton, customGoogleButton,
                                                   customFacebookButton, emailSignIn])
        stackButtons.axis = .vertical
        stackButtons.spacing = 10
        
        view.addSubview(stackButtons)
        stackButtons.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 40, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    
}


// MARK: - ResetPasswordControllerDelegate

extension SignInController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPasswordLink(_ controller: ResetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Exitoso", message: "Se ha enviado un correo a tu email.")
    }
}

extension SignInController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        
        if let accestoken = AccessToken.current?.tokenString {
            let credential = FacebookAuthProvider.credential(withAccessToken: accestoken)
            AuthService.signInWithThirdProvider(withCredential: credential) { error, isNewUser in
                if let error = error {
                    print("DEBUG: No se pudo iniciar sesión \(error.localizedDescription)")
                    return
                }
                
                if isNewUser {
                    self.showLoader(true)
                    AuthService.registerWithoutEmail { error in
                        if let error = error {
                            print("DEBUG: Hubo un error registrando al usuario: \(error.localizedDescription)")
                            return
                        }
                        print("Poniendo delegado nuevo usuario")
                        self.showLoader(false)
                        self.authDelegate?.authenticationDidComplete()
                    }
                    return
                }
                
                self.authDelegate?.authenticationDidComplete()
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Loggout facebook")
    }
}

extension SignInController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
       
            if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
               
                guard let nonce = currentNonce else {
                       fatalError("Invalid state: A login callback was received, but no login request was sent.")
                     }
                     guard let appleIDToken = appleIDCredential.identityToken else {
                       print("Unable to fetch identity token")
                       return
                     }
                     guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                       print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                       return
                     }
                     // Initialize a Firebase credential.
                     let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                               idToken: idTokenString,
                                                               rawNonce: nonce)
                
                AuthService.signInWithThirdProvider(withCredential: credential) { error, isNewUser in
                    if let error = error {
                        print("Error al registrar con apple: \(error.localizedDescription)")
                        return
                    }
                    
                    print("Es nuevo usuario: \(isNewUser)")
                    
                    if(isNewUser) {
                        self.showLoader(true)
                        AuthService.registerWithoutEmail { error in
                            if let error = error {
                                print("DEBUG: Hubo un error registrando al usuario: \(error.localizedDescription)")
                                return
                            }
                            print("Poniendo delegado nuevo usuario")
                            self.showLoader(false)
                            self.authDelegate?.authenticationDidComplete()
                        }
                        return
                    }
                    
                    self.authDelegate?.authenticationDidComplete()
                }
                
            }
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        guard let error = error as? ASAuthorizationError else { return }
        
        print(error.localizedDescription)
        
        
        switch error.code {
                case .canceled:
                    // user press "cancel" during the login prompt
                    print("Canceled")
                case .unknown:
                    // user didn't login their Apple ID on the device
                    print("Unknown")
                case .invalidResponse:
                    // invalid response received from the login
                    print("Invalid Respone")
                case .notHandled:
                    // authorization request not handled, maybe internet failure during login
                    print("Not handled")
                case .failed:
                    // authorization failed
                    print("Failed")
                @unknown default:
                    print("Default")
                }
    }
    
}

