//
//  ProfileViewController.swift
//  DropIt
//
//

import MessageUI
import Reachability
import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet private weak var emailView: UIView!
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var aboutView: UIView!
    @IBOutlet private weak var instagramView: UIView!
    @IBOutlet private weak var twitterView: UIView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var instagramTextField: UITextField!
    @IBOutlet private weak var twitterTextField: UITextField!
    @IBOutlet private weak var aboutTextView: UITextView!
    @IBOutlet private weak var editButton: UIBarButtonItem!
    @IBOutlet private weak var instagramButton: UIButton!
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var mailButton: UIButton!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    
    private var coreDataManager = CoreDataManager()
    private let moyaManager = MoyaManager()
    private let placeholderText = "Add information about yourself (200 symbols max)."
    private let textViewColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
    private var user = User()
    private var userId = 0
    private var id = 0
    private var aboutText = ""
    private var role = ""
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserId()
        setupTextView()
        getInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        instagramTextField.delegate = self
        twitterTextField.delegate = self
        loadingView.startAnimating()
        loadingView.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundView(emailView, nameView, instagramView, twitterView)
        addViewBorder(emailView, nameView, aboutView, instagramView, twitterView)
        roundButton(saveButton)
    }
    
    // MARK: - Setup
    private func setupTextView() {
        aboutTextView.delegate = self
        aboutTextView.text = placeholderText
        aboutTextView.textColor = textViewColor
        aboutTextView.tintColor = textViewColor
    }
    
    func setUserId(_ id: Int) {
        self.id = id
    }
    
    // MARK: - Logic
    private func getInfo() {
        if id == 0 || id == userId {
            getUser()
            getUserInfo()
        } else {
            print(id)
            getAnotherUser()
            editButton.isEnabled = false
            editButton.tintColor = .clear
        }
    }
    
    private func getUserId() {
        user = coreDataManager.getUser()
        userId = Int(user.id)
    }
    
    private func showUserInfo(_ email: String, _ name: String, _ aboutUser: String, _ instagram: String, _ twitter: String) {
        if email == "" {
            emailTextField.placeholder = ""
        } else {
            emailTextField.text = email
        }
        if name == "" {
            nameTextField.placeholder = ""
        } else {
            nameTextField.text = name
        }
        if instagram == "" {
            instagramTextField.placeholder = ""
        } else {
            instagramTextField.text = instagram
        }
        if twitter == "" {
            twitterTextField.placeholder = ""
        } else {
            twitterTextField.text = twitter
        }
        aboutTextView.text = aboutUser
    }
    
    private func getUserInfo() {
        user = coreDataManager.getUser()
        userId = Int(user.id)
        emailTextField.text = user.email
        nameTextField.text = user.name
        aboutTextView.text = user.aboutUser != "" ? user.aboutUser : placeholderText
        instagramTextField.text = user.instagramAccount
        twitterTextField.text = user.twitterAccount
        Sessions.token = user.token ?? ""
    }
    
    private func isCorrectLinks() -> Bool {
        if instagramTextField.text == "" || instagramTextField.text?.isInstagramValidate() == true {
            if twitterTextField.text == "" || twitterTextField.text?.isTwitterValidate() == true {
                return true
            }
        }
        return false
    }
    
    private func editAllowed(_ hidden: Bool, _ enabled: Bool) {
        saveButton.isHidden = hidden
        nameTextField.isEnabled = enabled
        instagramTextField.isEnabled = enabled
        twitterTextField.isEnabled = enabled
        aboutTextView.isUserInteractionEnabled = enabled
        aboutTextView.isEditable = enabled
        instagramButton.isHidden = enabled
        twitterButton.isHidden = enabled
    }
    
    // MARK: - API Calls
    private func getUser() {
        moyaManager.requestGetUser(userId, completion: { /*[weak self]*/ (responseCode, responseModel) in
            switch responseCode {
            case 200:
                print(responseModel)
                self.coreDataManager.addUser(responseModel.id, Sessions.token, responseModel.email)
                self.coreDataManager.updateUser(responseModel.id, responseModel.name, responseModel.aboutUser, responseModel.twitterAccount, responseModel.instagramAccount)
                self.getUserInfo()
                self.loadingView.stopAnimating()
                self.loadingView.isHidden = true
            case 404:
                print("No user")
            default:
                self.getUserInfo()
                print("Error")
            }
        })
    }
    
    private func getAnotherUser() {
        moyaManager.requestGetUser(self.id, completion: { /*[weak self]*/ (responseCode, responseModel) in
            switch responseCode {
            case 200:
                print(self.id)
                print(responseModel)
                self.showUserInfo(responseModel.email, responseModel.name, responseModel.aboutUser, responseModel.instagramAccount, responseModel.twitterAccount)
                self.loadingView.stopAnimating()
                self.loadingView.isHidden = true
            case 404:
                print("No user")
            default:
                self.getUserInfo()
                print("Error")
            }
        })
    }
    
    private func updateUser() {
        if aboutTextView.text != "Add information about yourself (200 symbols max)." {
            aboutText = aboutTextView.text
        }
        moyaManager.requestUpdateUser(self.userId, nameTextField.text ?? "", aboutText, instagramTextField.text ?? "" , twitterTextField.text ?? "", completion: {(responseCode, responseModel) in
            switch responseCode {
            case 200:
                self.coreDataManager.updateUser(self.userId, self.nameTextField.text ?? "", self.aboutText, self.twitterTextField.text ?? "", self.instagramTextField.text ?? "")
                print(responseModel)
            case 401:
                print("Invalid profile data")
            case 403:
                print("User is trying to update other user's information")
            case 404:
                print("No user")
            default:
                print("Error")
            }
        })
    }
    
    private func openLink(url: String) {
        if let url = URL(string: url) { UIApplication.shared.open(url, options: [:], completionHandler: nil)}
    }
    
    private func openInstagram() {
        if instagramTextField.text != "" {
            openLink(url: "https://www.instagram.com/\(instagramTextField.text ?? "")")
        }
    }
    
    private func openTwitter() {
        if twitterTextField.text != "" {
            openLink(url: "https://twitter.com/\(twitterTextField.text ?? "")")
        }
    }
    
    // MARK: - Actions
    @IBAction private func tappedBackButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func tappedEditButton(_ sender: UIBarButtonItem) {
        editAllowed(false, true)
    }
    
    @IBAction private func tappedSaveButton(_ sender: UIButton) {
        if isCorrectLinks() {
            editAllowed(true, false)
            checkConnection()
            if let connection = reachability?.connection {
                switch connection {
                case .wifi, .cellular:
                    updateUser()
                case .none, .unavailable:
                    showAlert("No Connection","Anable to connect, please check your internet connection.")
                }
            }
        } else {
            showAlert("Please write correct datas","Please check information in your profile.")
        }
    }
    
    @IBAction private func tappedInstagram(_ sender: UIButton) {
        checkConnection()
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                openInstagram()
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
    
    @IBAction private func tappedTwitter(_ sender: UIButton) {
        checkConnection()
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                openTwitter()
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
    
    @IBAction private func tappedMail(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("DVIRAL link")
            mail.setToRecipients([emailTextField.text ?? ""])
            mail.setMessageBody("Hello! ", isHTML: false)
            present(mail, animated: true)
        } else {
            print("Error With Email")
        }
    }
}

// MARK: - Extentions
// MARK: - UITextViewDelegate
extension ProfileViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if range.length +  range.location > aboutTextView.text.count {
//            return false
//        }
        let limitText = aboutTextView.text.count + text.count - range.length
        return limitText < 201
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if aboutTextView.text == placeholderText {
            textView.text = ""
            textView.textColor = textViewColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = textViewColor
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension ProfileViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        }
}
