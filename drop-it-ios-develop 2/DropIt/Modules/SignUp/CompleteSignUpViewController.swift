//
//  CompleteSignUpViewController.swift
//  DropIt
//
//

import UIKit

class CompleteSignUpViewController: UIViewController {
    
    @IBOutlet private weak var completeSignUpButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundButton(completeSignUpButton)
    }
    
    // MARK: - Actions
    @IBAction private func unwindSegueToSignIn(segue: UIStoryboardSegue) {
        guard segue.identifier == "unwindToSignInVCSegue" else {return}
        guard segue.destination as? SignInViewController != nil else {return}
    }
}
