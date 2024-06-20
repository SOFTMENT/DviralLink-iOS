//
//  SignUpViewController.swift
//  DropIt
//
//

import Moya
import UIKit

class SignUpViewController: BaseViewController {
    @IBOutlet private weak var emailView: UIView!
    @IBOutlet private weak var passwordView: UIView!
    @IBOutlet private weak var confirmPasswordView: UIView!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var passwordInfoButton: UIButton!
    @IBOutlet private weak var eyeConfirmPasswordButton: UIButton!
    @IBOutlet private weak var eyePasswordButton: UIButton!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var errorPasswordLabel: UILabel!
    @IBOutlet private weak var errorConfirmPasswordLabel: UILabel!
    @IBOutlet private weak var errorEmailLabel: UILabel!
    @IBOutlet private weak var registerButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var passwordTopConstarint: NSLayoutConstraint!
    @IBOutlet private weak var confirmPasswordTopConstraint: NSLayoutConstraint!
    
    private let moyaManager = MoyaManager()
    private var isEmailEmpty = true
    private var isPasswordEmpty = true
    private var isConfirmPasEmpty = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundView(emailView, passwordView, confirmPasswordView)
        roundButton(registerButton)
    }
    
    // MARK: - Logic
    private func isDatasEmpty() -> Bool {
        isEmailEmpty = isTextFieldEmpty(emailView, emailTextField, "Please enter your email address", "E-mail")
        isPasswordEmpty = isTextFieldEmpty(passwordView, passwordTextField, "Please enter your password", "Password")
        isConfirmPasEmpty = isTextFieldEmpty(confirmPasswordView, confirmPasswordTextField, "Please enter your password", "Confirm Password")
        if isEmailEmpty || isPasswordEmpty || isConfirmPasEmpty {
            return false
        }
        return true
    }
    
    private func isCorrectDatas() -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        if isDatasEmpty() {
             showAnimation(errorEmailLabel, passwordTopConstarint, emailTextField.text?.isEmailValidate() ?? false)
             showAnimation(errorPasswordLabel, confirmPasswordTopConstraint, passwordTextField.text?.isPasswordValidate() ?? false)
             let matchPassword = passwordTextField.text != confirmPasswordTextField.text ? false : true
             showAnimation(errorConfirmPasswordLabel, registerButtonTopConstraint, matchPassword)
            if errorEmailLabel.alpha == 0 && errorPasswordLabel.alpha == 0 && errorConfirmPasswordLabel.alpha == 0 {
                return true
            }
        }
        return false
    }
    
    // MARK: - API Calls
    private func signUp() {
        moyaManager.requestSignUp(emailTextField.text ?? "", passwordTextField.text ?? "", confirmPasswordTextField.text ?? "", completion: { [weak self] (responseCode) in
            switch responseCode {
            case 202:
                self?.performSegue(withIdentifier: "toCompleteSignUpSegue", sender: nil)
            case 400:
                self?.errorConfirmPasswordLabel.text = "Email already exists. Please enter another email."
            default:
                self?.errorConfirmPasswordLabel.text = "Server Error. Please try again."
            }
        })
        showAnimation(errorConfirmPasswordLabel, registerButtonTopConstraint, false)
    }
    
    // MARK: - Actions
    @IBAction private func tappedEyeConfirmPassword(_ sender: UIButton) {
        hidePassword(confirmPasswordTextField, eyeConfirmPasswordButton)
    }

    @IBAction private func tappedEyePassword(_ sender: UIButton) {
        hidePassword(passwordTextField, eyePasswordButton)
    }
    
    @IBAction private func tappedPasswordInfo(_ sender: UIButton) {
        showPasswordInfo(passwordInfoButton, 2)
    }
    
    @IBAction private func tappedRegister(_ sender: UIButton) {
        if isCorrectDatas() {
            checkConnection()
            if let connection = reachability?.connection {
                switch connection {
                case .wifi, .cellular:
                    signUp()
                case .none, .unavailable:
                    showAlert("No Connection","Anable to connect, please check your internet connection.")
                }
            }
         }
    }
    
    @IBAction private func tappedConditions(_ sender: UIButton) {
        performSegue(withIdentifier: "toConditionsSegue", sender: nil)
    }
    
    @IBAction private func unwindSegueToSignUp(segue: UIStoryboardSegue) {
        guard segue.identifier == "unwindToSignUpVCSegue" else {return}
        guard segue.destination as? SignUpViewController != nil else {return}
    }
}
