//
//  MenuViewController.swift
//  DropIt
//
//

import GoogleSignIn
import UIKit
import Firebase


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
        GIDSignIn.sharedInstance.signOut()
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
    
    @IBAction func deleteAccountBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive,handler: { action in
          
            self.coreDataManager.removeUser()
            self.beRootScreen(mIdentifier: "SignInViewController")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    
    func beRootScreen(mIdentifier : String) {


        guard let window = self.view.window else {
            self.view.window?.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
            self.view.window?.makeKeyAndVisible()
                return
            }

            window.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
            window.makeKeyAndVisible()
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)

    }
    
    func getViewControllerUsingIdentifier(mIdentifier : String) -> UIViewController{

        let mainStoryboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
        return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? SignInViewController)!

    }
}
