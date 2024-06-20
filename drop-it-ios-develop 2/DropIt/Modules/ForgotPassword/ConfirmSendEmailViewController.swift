//
//  ConfirmSendEmailViewController.swift
//  DropIt
//
//

import UIKit

class ConfirmSendEmailViewController: UIViewController {
    
    @IBOutlet private weak var okButton: UIButton!
    
    private var email: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundButton(okButton)
    }
    
    // MARK: - Setup
    func setEmail(_ email: String?) {
        self.email = email
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toNewPasswordSegue" else { return }
        guard let destinationVC = segue.destination as? UINavigationController else { return }
        if let confirmVC = destinationVC.viewControllers[0] as? NewPasswordViewController {
            confirmVC.setEmail(email)
        }
    }

    // MARK: - Actions
    @IBAction private func tappedOkButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toNewPasswordSegue", sender: nil)
    }
    
}
