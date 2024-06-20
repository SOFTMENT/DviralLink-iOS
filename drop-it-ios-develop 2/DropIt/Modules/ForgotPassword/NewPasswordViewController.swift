//
//  NewPasswordViewController.swift
//  DropIt
//
//

import AMPopTip
import UIKit

class NewPasswordViewController: BaseViewController {
    
    @IBOutlet private weak var passwordView: UIView!
    @IBOutlet private weak var confirmPasswordView: UIView!
    @IBOutlet private weak var passwordEyeButton: UIButton!
    @IBOutlet private weak var confirmEyeButton: UIButton!
    @IBOutlet private weak var passwordInfoButton: UIButton!
    @IBOutlet private weak var changePasswordButton: UIButton!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmTextField: UITextField!
    @IBOutlet private weak var confirmViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var buttonTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var errorPasswordLabel: UILabel!
    @IBOutlet private weak var errorConfirmLabel: UILabel!
    
    private var isPasswordEmpty = true
    private var isConfirmPasEmpty = true
    private var isCorrectCode = true
    private var email: String?
    private let moyaManager = MoyaManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        confirmTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundView(confirmPasswordView, passwordView)
        roundButton(changePasswordButton)
    }
    
    // MARK: - Logic
    func setEmail(_ email: String?) {
        self.email = email
    }
    
    private func isPasswordsEmpty() -> Bool {
        passwordTextField.resignFirstResponder()
        confirmTextField.resignFirstResponder()
        isPasswordEmpty = isTextFieldEmpty(passwordView, passwordTextField, "Please enter your password", "Password")
        isConfirmPasEmpty = isTextFieldEmpty(confirmPasswordView, confirmTextField, "Please enter your password", "Confirm Password")
        if !isPasswordEmpty && !isConfirmPasEmpty { return true }
        return false
    }
    
    private func isCorrectPasswords() -> Bool {
        if isPasswordsEmpty() {
            showAnimation(errorPasswordLabel, confirmViewTopConstraint, passwordTextField.text?.isPasswordValidate() ?? false)
            let matchPassword = passwordTextField.text != confirmTextField.text ? false : true
            showAnimation(errorConfirmLabel, buttonTopConstraint, matchPassword)
            if errorPasswordLabel.alpha == 0 && errorConfirmLabel.alpha == 0 {
                return true
            }
        }
        return false
    }
    
    // MARK: - API Calls
    private func changePassword() {
        moyaManager.requestSetPassword(email ?? "", passwordTextField.text ?? "", confirmTextField.text ?? "", completion: { [weak self] (responseCode) in
            switch responseCode {
            case 200:
                self?.performSegue(withIdentifier: "toConfirmChangedPasswordSegue", sender: nil)
            case 400:
                self?.errorConfirmLabel.text = "The retrieve password link is expired.\nPlease repeat the password change\n process one more time."
            default:
                self?.errorConfirmLabel.text = "Server Error. Please try again."
            }
        })
        showAnimation(errorConfirmLabel, buttonTopConstraint, false)
    }
    
    // MARK: - Actions
    @IBAction private func tappedEyeButton(_ sender: UIButton) {
        hidePassword(passwordTextField, passwordEyeButton)
    }
    
    @IBAction private func tappedConfirmEyeButton(_ sender: UIButton) {
        hidePassword(confirmTextField, confirmEyeButton)
    }
    
    @IBAction private func tappedInfoButton(_ sender: UIButton) {
        showPasswordInfo(passwordInfoButton, 1)
    }
    
    @IBAction private func tappedChangeButton(_ sender: UIButton) {
        checkConnection()
        if isCorrectPasswords() {
            if let connection = reachability?.connection {
                switch connection {
                case .wifi, .cellular:
                    changePassword()
                case .none, .unavailable:
                    showAlert("No Connection","Anable to connect, please check your internet connection.")
                }
            }
        }
    }
    
    @IBAction private func tappedBackToForgotPassword(_ sender: UIBarButtonItem) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}
