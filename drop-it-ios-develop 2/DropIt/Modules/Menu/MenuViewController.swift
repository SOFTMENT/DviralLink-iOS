//
//  MenuViewController.swift
//  DropIt
//
//

import GoogleSignIn
import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet private weak var profileButton: UIButton!
    
    private var coreDataManager = CoreDataManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction private func tappedProfileButton(_ sender: UIButton) {
        performSegue(withIdentifier: "toProfileSegue", sender: nil)
    }
    
    @IBAction private func tappedLogoutButton(_ sender: UIButton) {
        coreDataManager.removeUser()
        GIDSignIn.sharedInstance().signOut()
        let vc = UIStoryboard(name: "SignIn", bundle: nil).instantiateViewController(identifier: "SignInViewController")
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
    
    @IBAction private func tappedBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction private func tappedTerms(_ sender: UIButton) {
        performSegue(withIdentifier: "toTermsSegue", sender: nil)
    }
    
    @IBAction private func tappedAboutTheApp(_ sender: UIButton) {
        performSegue(withIdentifier: "toAboutThneAppSegue", sender: nil)
    }
}
