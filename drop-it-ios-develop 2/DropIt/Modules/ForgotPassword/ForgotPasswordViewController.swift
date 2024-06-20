//
//  ForgotPasswordViewController.swift
//  DropIt
//
//

import Reachability
import UIKit

class ForgotPasswordViewController: BaseViewController {
    
    @IBOutlet private weak var emailView: UIView!
    @IBOutlet private weak var sendEmailButton: UIButton!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var errorEmailLabel: UILabel!
    @IBOutlet private weak var sendEmailButtonTopConstraint: NSLayoutConstraint!
    
    private let moyaManager = MoyaManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundView(emailView)
        roundButton(sendEmailButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showAnimation(errorEmailLabel, sendEmailButtonTopConstraint, true)
    }
    
    // MARK: - Logic
    private func isTextFieldEmpty() -> Bool {
        if !isTextFieldEmpty(emailView, emailTextField, "Please enter your email address", "E-mail") { return true } else { return false }
    }
    
    private func isCorrectEmail() -> Bool {
        emailTextField.resignFirstResponder()
        if isTextFieldEmpty() {
            showAnimation(errorEmailLabel, sendEmailButtonTopConstraint, emailTextField.text?.isEmailValidate() ?? false)
            if errorEmailLabel.alpha == 0 {
                return true
            }
        }
        return false
    }
    
    private func changeStyleView() {
        emailView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor.red.cgColor
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toConfirmSendEmailSegue" else { return }
        guard let destinationVC = segue.destination as? UINavigationController else { return }
        if let confirmVC = destinationVC.viewControllers[0] as? ConfirmSendEmailViewController {
            confirmVC.setEmail(emailTextField.text)
        }
    }
    
    // MARK: - API Calls
    private func resetPassword() {
        moyaManager.requestResetPassword(emailTextField.text ?? "", completion: { [weak self] (responseCode) in
            switch responseCode {
            case 202:
                self?.performSegue(withIdentifier: "toConfirmSendEmailSegue", sender: nil)
            case 404:
                self?.errorEmailLabel.text = "We don't have an account for that email.\nTry to register instead."
            default:
                self?.errorEmailLabel.text = "Server Error. Please try again."
            }
        })
        showAnimation(errorEmailLabel, sendEmailButtonTopConstraint, false)
    }
    
    // MARK: - Actions
    @IBAction private func tappedSendEmail(_ sender: Any) {
        if isCorrectEmail() {
            checkConnection()
            if let connection = reachability?.connection {
                switch connection {
                case .wifi, .cellular:
                    resetPassword()
                case .none, .unavailable:
                    showAlert("No Connection","Anable to connect, please check your internet connection.")
                }
            }
        }
    }
    
}
