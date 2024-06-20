//
//  ViewController.swift
//  DropIt
//
//

import AuthenticationServices
import GoogleSignIn
import Reachability
import UIKit

class SignInViewController: BaseViewController {
    
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var emailTextField: UITextField!
    @IBOutlet weak private var emailView: UIView!
    @IBOutlet weak private var passwordView: UIView!
    @IBOutlet weak private var eyeButton: UIButton!
    @IBOutlet weak private var errorLabel: UILabel!
    @IBOutlet weak private var forgotTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var signInButton: UIButton!
    @IBOutlet weak private var signInGoogleButton: UIButton!
    @IBOutlet weak private var signInwithAppleButton: UIButton!
    
    private let moyaManager = MoyaManager()
    private let coreDataManager = CoreDataManager()
    private let appleManager = AppleService()
    private var isEmailEmpty = true
    private var isPasswordEmpty = true
    private var token: Data? = Data()
    private var currentNonce: String?

  
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
       
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showAnimation(errorLabel, forgotTopConstraint, true)
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundView(emailView, passwordView)
        roundButton(signInGoogleButton, signInButton, signInwithAppleButton)
    }
    
    // MARK: - Apple Functions
    func performAppleSignIn() {
        let appleIdDetails = ASAuthorizationAppleIDProvider()
        let request = appleIdDetails.createRequest()
        request.requestedScopes = [.email, .fullName]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let details = authorization.credential as? ASAuthorizationAppleIDCredential {
           let appleToken = String(data: details.identityToken!, encoding: .utf8) ?? "No token"
            print(appleToken)
            let user = decode(jwtToken: appleToken)
            let mail = UserToken.init(data: user).email
            signInWithApple(appleToken, mail)
        }
    }
    
    func accountDeleted() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedOperation = .operationLogout
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.performRequests()
    }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription + " sad :(")
    }
    
    // MARK: - Logic
    private func isDatasEmpty() -> Bool {
        isEmailEmpty = isTextFieldEmpty(emailView, emailTextField, "Please enter your email address", "E-mail")
        isPasswordEmpty = isTextFieldEmpty(passwordView, passwordTextField, "Please enter your password", "Password")
        if isEmailEmpty || isPasswordEmpty { return false } else { return true }
    }
    
    private func isRightDatas() -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        if isDatasEmpty() {
            showAnimation(errorLabel, forgotTopConstraint, true)
            if errorLabel.alpha == 0 {
                return true
            }
        }
        return false
    }
    
    private func changeStyleView() {
        emailView.layer.borderWidth = 1
        passwordView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor.red.cgColor
        passwordView.layer.borderColor = UIColor.red.cgColor
    }
    
    // MARK: - API Calls
    private func signIn() {
        moyaManager.requestSignIn(emailTextField.text ?? "", passwordTextField.text ?? "", completion: { [weak self] (responseCode, responseModel) in
            switch responseCode {
            case 200:
                self?.coreDataManager.addUser(self?.getId(token: responseModel.token) ?? 0, responseModel.token, self?.emailTextField.text ?? "")
                self?.coreDataManager.addRole(self?.getId(token: responseModel.token) ?? 0, self?.getRole(token: responseModel.token) ?? "")
                Sessions.token = responseModel.token
                self?.performSegue(withIdentifier: "welcomeSeg", sender: nil)
            case 401:
                self?.errorLabel.text = "Email or password is incorrect.Please try again."
            case 406:
                self?.errorLabel.text = "Account is not confirmed.Please check your mail."
            default:
                self?.errorLabel.text = "Server Error. Please try again."
            }
        })
        showAnimation(errorLabel, forgotTopConstraint, false)
    }
    
    private func getId (token : String) -> Int {
        let user = decode(jwtToken: token)
        let id = UserToken.init(data: user).id
        return id
    }
    
    private func getRole (token : String) -> String {
        let user = decode(jwtToken: token)
        let role = UserToken.init(data: user).role
        return role
    }
    
    private func signInwithGoogle(_ token: String, _ email: String) {
     
        moyaManager.requestSocialSignIn(token, "GOOGLE", completion: { [weak self] (responseCode, responseModel) in
            print("RATHORE \(responseCode)")

            switch responseCode {
            case 200:
                if responseModel.token != "" {
                    print("AJAY")
                    self?.coreDataManager.addUser(self?.getId(token: responseModel.token) ?? 0, responseModel.token, email)
                    self?.coreDataManager.addRole(self?.getId(token: responseModel.token) ?? 0, self?.getRole(token: responseModel.token) ?? "")
                    print(responseModel.token)
                    Sessions.token = responseModel.token
                    self?.performSegue(withIdentifier: "welcomeSeg", sender: nil)
                } else {
                
                    self?.errorLabel.text = "Server Error. Please try again."
                }
            default:
                
                self?.errorLabel.text = "Server Error. Please try again."
            }
        })
    }
    
    private func signInWithApple(_ token: String, _ email: String) {
        moyaManager.requestSocialSignIn(token, "APPLE", completion: { [weak self] (responseCode, responseModel) in
            switch responseCode {
            case 200:
                if responseModel.token != "" {
                    self?.coreDataManager.addUser(self?.getId(token: responseModel.token) ?? 0, responseModel.token, email)
                    self?.coreDataManager.addRole(self?.getId(token: responseModel.token) ?? 0, self?.getRole(token: responseModel.token) ?? "")
                    Sessions.token = responseModel.token
                    self?.performSegue(withIdentifier: "welcomeSeg", sender: nil)
                } else {
                    self?.errorLabel.text = "Server Error. Please try again."
                }
            default:
                self?.errorLabel.text = "Server Error. Please try again."
            }
        })
    }
    
    // MARK: - Actions
    @IBAction private func tappedForgotPassword(_ sender: UIButton) {
        performSegue(withIdentifier: "toForgotPasswordSegue", sender: nil)
    }
    
    @IBAction private func tappedEyePasswordButton(_ sender: UIButton) {
       hidePassword(passwordTextField, eyeButton)
    }
    
    @IBAction private func tappedRegister(_ sender: UIButton) {
        performSegue(withIdentifier: "toSignUpSegue", sender: nil)
    }
    
    @IBAction private func tappedSignIn(_ sender: UIButton) {
        checkConnection()
        if isRightDatas() {
            if let connection = reachability?.connection {
                switch connection {
                case .wifi, .cellular:
                    signIn()
                case .none, .unavailable:
                    showAlert("No Connection","unable to connect, please check your internet connection.")
                }
            } else { // alert
            }
         } else { changeStyleView() }
    }
    
    @IBAction private func tappedConditions(_ sender: UIButton) {
        performSegue(withIdentifier: "toConditionsSegue", sender: nil)
    }
    
    @IBAction private func unwindSegueToSignIn(segue: UIStoryboardSegue) {
        guard segue.identifier == "unwindToSignInVCSegue" else {return}
        guard segue.destination as? SignInViewController != nil else {return}
    }
    
    @IBAction private func tappedSignInGoogle(_ sender: UIButton) {
        let signInConfig = GIDConfiguration.init(clientID: "433991664196-m03vlke4aaompb82djhff4c268shqvq8.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.signIn(
            with: signInConfig,
            presenting: self // your view controller
        ) { user, error in
          
            if let token = user?.authentication.accessToken {
                
                self.signInwithGoogle(token, user!.profile!.email)
                return
            }
            guard let error = error as? GIDSignInError else {
                fatalError("No token and no GIDSignInError: \(String(describing: error))")
            }
           
        }
    }
    
    @IBAction private func tappedSignInWithApple(_ sender: UIButton) {
        performAppleSignIn()
    }
}



// MARK: - ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate
extension SignInViewController: ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}
