//
//  ConfirmPasswordViewController.swift
//  DropIt
//
//

import UIKit

class ConfirmPasswordViewController: UIViewController {
    
    @IBOutlet private weak var backToSignInButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundButton(backToSignInButton)
    }
}
