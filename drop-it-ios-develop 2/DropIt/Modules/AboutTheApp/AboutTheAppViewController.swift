//
//  SettingsViewController.swift
//  DropIt
//
//

import MessageUI
import UIKit

class AboutTheAppViewController: UIViewController {
    @IBOutlet private weak var aboutLabel: UILabel!
    @IBOutlet private weak var mailButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutLabel.text = "The  DViral Link App, is a platform that allows different individuals to network and stream each other's music, videos and social media  data. In order to share their projects, the users  drop a link on their feed,  after clicking on 5 LINKS and watch  at least 30 seconds of each you can post your own. The goal is to help our users generate streams and building a consistent audience. The app strives to target all creative audiences."
    }
    
    // MARK: - Logic
    private func openLink(url: String) {
        if let url = URL(string: url) { UIApplication.shared.open(url, options: [:], completionHandler: nil)}
    }
    
    // MARK: - Actions
    @IBAction private func tappedBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction private func tappedTelegram(_ sender: UIButton) {
        openLink(url: "https://telegram.org")
    }
    
    @IBAction private func tappedInstagram(_ sender: UIButton) {
        openLink(url: "https://www.instagram.com/")
    }
    
    @IBAction private func tappedMail(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("DVIRAL link")
            mail.setToRecipients(["fitzentrepreneur@gmail.com"])
            mail.setMessageBody("Hello! ", isHTML: false)
            present(mail, animated: true)
        } else {
            print("Error With Email")
        }
    }
}

// MARK: - Extentions
// MARK: - MFMailComposeViewControllerDelegate
extension AboutTheAppViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss(animated: true)
        }
}
