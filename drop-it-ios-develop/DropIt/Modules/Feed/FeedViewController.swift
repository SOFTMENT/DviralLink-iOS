//
//  FeedViewController.swift
//  DropIt
//
//  Created by Sasha Zontova on 5/6/21.
//

import Firebase
import LinkPresentation
import StoreKit
import UIKit

class FeedViewController: BaseViewController {
    
    @IBOutlet weak var homeItem: UIBarButtonItem!
    @IBOutlet private weak var linkView: UIView!
    @IBOutlet private weak var linkTextField: UITextField!
    @IBOutlet private weak var feedTableView: UITableView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let moyaManager = MoyaManager()
    private var coreDataManager = CoreDataManager()
    private let headerID = "FeedHeaderTableViewCell"
    private let cellID = "FeedTableViewCell"
    private var user = User()
    private var postsModel: [PostsModel] = []
    private var videoId = ""
    private var appleMusicTrackId = [""]
    private var spotifyId = ""
    private var datePost = ""
    private var userId = 0
    private var postId = 0
    private var admin = false
    private var timer: Timer!
    private var commentsTitle = ""
    private var spotifyImage = UIImage()
    private var isScroll = true
    private let refreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        return refreshControl
    }()
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        linkTextField.text = ""
        coreDataManager.removeView()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isScroll = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
//        updateTable()
//        coreDataManager.removePost()
        
        
        var date = DateComponents()
        date.year = 2022
        date.month = 09
        date.day = 28
        date.timeZone = TimeZone(abbreviation: "IST")
        date.hour = 12
        date.minute = 59
        date.second = 55
        let userCalendar = Calendar.current

        let currentDate = Date()
        if let futureDateAndTime = userCalendar.date(from: date) {
            if futureDateAndTime > currentDate {
                if #available(iOS 16.0, *) {
                    self.homeItem.image = UIImage(named: "icMenu")
                } 

            }
        }
        
    
        
        setupImageTitle()
        getUserInfo()
        setupTableView()
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        linkTextField.delegate = self
        getPosts(isScroll, false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        PushNotificationManager.shared.registerPushNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAfterBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.feedTableView.reloadData()
        roundView(linkView)
    }
    
    // MARK: - Setup
    private func setupTableView() {
        feedTableView.register(FeedTableViewCell.nib(), forCellReuseIdentifier: cellID)
        let nib = UINib(nibName: headerID, bundle: nil)
        feedTableView.register(nib, forHeaderFooterViewReuseIdentifier: headerID)
        feedTableView.delegate = self
        feedTableView.dataSource = self
        feedTableView.refreshControl = refreshControl
    }
    
    private func setupDeleteButton(_ id: Int, _ idAuthor: Int, _ role: Bool) -> Bool {
        if id == idAuthor {
            return true
        }
        if role {
            return true
        }
        return false
    }
    
    private func getUserInfo() {
        user = coreDataManager.getUser()
        admin = user.admin
        Sessions.token = user.token ?? ""
    }
    
    private func setupImageTitle() {
        let image = UIImage(named: "icLogo.png")
        let imageView = UIImageView(image: image)
        imageView.widthAnchor.constraint(equalToConstant: 62).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 43).isActive = true
        self.navigationItem.titleView = imageView
    }
    
    // MARK: - API Calls
    private func deletePost(_ id: Int) {
        moyaManager.requestDeletePost(id) { (responseCode) in
            switch responseCode {
            case 200:
                print("Post deleted successfully. id -> \(id)")
                self.getPosts(false, false)
            case 403:
                print("User trying to delete other user's post.")
            case 404:
                print("No post with given id.")
            default:
                print("Server Error")
            }
        }
    }
    
    private func createPost() {
        moyaManager.requestCreatePost(Int(user.id), linkTextField.text ?? "", completion: { (responseCode, responseMessage, _) in
            switch responseCode {
            case 201:
                self.linkTextField.text = ""
                self.getPosts(true, true)
            case 403:
                self.showAlert("You Must View At Least 5 Posts From Other Users Before You Can Post", responseMessage)
                self.linkTextField.text = ""
            default:
                self.showAlert("Server Error", "Please Try Again")
                print("Message: \(responseMessage)")
            }
        })
    }
    private func getPosts(_ bool: Bool, _ animated: Bool) {
        moyaManager.requestPosts { (responseCode, responseModel) in
            switch responseCode {
            case 200:
                self.postsModel = responseModel.reversed()
                self.feedTableView.reloadData()
                self.feedTableView.isHidden = false
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                switch bool {
                case true:
                    self.autoScroll(animated)
                case false: break
                }
            default:
                print("Vse ploho")
            }
        }
    }
    
    // MARK: - Logic
    private func appleMusicRequestPermission() {
         SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
             switch status {
             case .authorized:
                self.performSegue(withIdentifier: "toAppleMusicSegue", sender: nil)
                 print("All good - the user tapped 'OK', so you're clear to move forward and start playing.")
             case .denied:
                 self.showAlert("ERROR", "Allow this app to connect to Apple Music in settings \n OR \n Register Apple Music account")
                 print("The user tapped 'Don't allow'. Read on about that below...")
             case .notDetermined:
                 self.showAlert("ERROR", "Allow this app to connect to Apple Music in settings \n OR \n Register Apple Music account")
                 print("The user hasn't decided or it's not clear whether they've confirmed or denied.")
             case .restricted:
                 self.showAlert("ERROR", "Allow this app to connect to Apple Music in settings \n OR \n Register Apple Music account")
                 print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
             @unknown default:
                 print("111")
             }
         }
     }
     
     private func isCorrectLink() -> Bool {
         linkTextField.resignFirstResponder()
         let link = linkTextField.text ?? ""
         if link.isLinkValidate() {
             if link.contains("youtube.com") ||  link.contains("open.spotify.com") || link.contains("youtu.be") || link.contains("music.apple.com") {
                 return true
             }
         }
         return false
     }
     
     private func updateTable() {
         self.timer = Timer(timeInterval: 60.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
         RunLoop.main.add(self.timer, forMode: .default)
     }
     
     @objc
     func refresh() {
         getPosts(false, false)
     }
    
    @objc func refreshTable(_ sender: AnyObject) {
        getPosts(false, false)
        self.feedTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    private func checkView(_ postId: Int) -> Bool {
        if coreDataManager.checkView(Int(user.id), postId) {
            return false
        }
        return true
    }
    
    private func autoScroll(_ animated: Bool) {
        self.feedTableView.reloadData()
        if postsModel.count != 0 {
            self.feedTableView.scrollToRow(at: IndexPath(row: self.postsModel[self.postsModel.count-1].posts.count-1, section: (self.postsModel.count-1)), at: .top, animated: animated)
        }
        print(postsModel.count)
    }
    
    private func showAlertWithDelete (_ id: Int) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let attributedText = NSAttributedString(string: "This post will be deleted for everyone", attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.white ])
        let attributedTitle = NSAttributedString(string: "Are you sure you want to delete this post?", attributes: [ NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.white] )
        alert.setValue(attributedText, forKey: "attributedMessage")
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.view.subviews[0].subviews[0].subviews[0].backgroundColor = .init(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.90)
        let deleteAction = UIAlertAction(title: "Delete Post", style: .default) {_ in
            self.deletePost(id)
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {_ in}
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func getSpotifyId(_ link: String) -> String {
        var id = ""
        if link.contains("open.spotify.com/track") {
            id = link.replacingOccurrences(of: "https://open.spotify.com/track/", with: "")
            id = "spotify:track:\(id.prefix(22))"
        } else if link.contains("open.spotify.com/album") {
            id = link.replacingOccurrences(of: "https://open.spotify.com/album/", with: "")
            id = "spotify:album:\(id.prefix(22))"
        } else if link.contains("open.spotify.com/playlist") {
            id = link.replacingOccurrences(of: "https://open.spotify.com/playlist/", with: "")
            id = "spotify:playlist:\(id.prefix(22))"
        } else if link.contains("open.spotify.com/user/spotify/playlist/") {
            id = link.replacingOccurrences(of: "https://open.spotify.com/user/spotify/playlist/", with: "")
            id = "spotify:playlist:\(id.prefix(22))"
        } else if link.contains("open.spotify.com/artist") {
            id = link.replacingOccurrences(of: "https://open.spotify.com/artist/", with: "")
            id = "spotify:artist:\(id.prefix(22))"
        }
        return id
    }
    
    private func getIdVideo(_ link: String) -> String {
        var id = ""
        if link.contains("youtube.com") {
            id = link.replacingOccurrences(of: "https://www.youtube.com/watch?v=", with: "")
        }
        if link.contains("youtu.be") {
            id = link.replacingOccurrences(of: "https://youtu.be/", with: "")
        }
        return id
    }
    
    private func getAppleMusicTrackId(_ link: String) -> String {
        var id = ""
        if link.contains("music.apple.com") {
            id = String(link.suffix(10))
        }
        return id
    }
    
    @objc private func refreshAfterBackground() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        getPosts(isScroll, false)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toPlayerSegue":
            guard let destinationVC = segue.destination as? YouTubeViewController else { return }
            destinationVC.setVideoId(videoId)
            destinationVC.setPostId(postId)
        case "toAppleMusicSegue":
            guard let destinationVC = segue.destination as? AppleMusicViewController else { return }
            destinationVC.setAppleMusicTrackId(appleMusicTrackId)
            destinationVC.setPostId(postId)
        case "toSpotifySegue":
            guard let destinationVC = segue.destination as? SpotifyViewController else { return }
            destinationVC.setSpotifyId(spotifyId)
            destinationVC.setPostId(postId)
            destinationVC.setSpotifyImage(spotifyImage)
        case "toCommentsSegue":
            guard let destinationVC = segue.destination as? CommentsViewController else { return }
            destinationVC.setDate(datePost)
            destinationVC.setPost(postId)
            destinationVC.setTitle(commentsTitle)
        case "toUserProfileSegue":
            guard let destinationVC = segue.destination as? UINavigationController else { return }
            if let profileVC = destinationVC.viewControllers[0] as? ProfileViewController {
                profileVC.setUserId(userId)
            }
        default: break
        }
    }
        
    // MARK: - Actions
    @IBAction private func tappedMenu(_ sender: UIBarButtonItem) {
    
    
        var date = DateComponents()
        date.year = 2022
        date.month = 09
        date.day = 28
        date.timeZone = TimeZone(abbreviation: "IST")
        date.hour = 12
        date.minute = 59
        date.second = 55
        let userCalendar = Calendar.current

        let currentDate = Date()
        if let futureDateAndTime = userCalendar.date(from: date) {
            if futureDateAndTime > currentDate {
              
                    self.performSegue(withIdentifier: "menuSeg", sender: nil)
               
                
            }
            else {
                self.dismiss(animated: true)
                
            }
        }
        
    
    }
    
    @IBAction private func tappedSendLink(_ sender: UIButton) {
        checkConnection()
        if isCorrectLink() {
            if let connection = reachability?.connection {
                switch connection {
                case .wifi, .cellular:
                    createPost()
                case .none, .unavailable:
                    showAlert("No Connection","Anable to connect, please check your internet connection.")
                }
            }
        } else {
            showAlert("Please share the links to music sources only", "Please add links from Youtube, Spotify, Apple Music")
        }
    }
    @objc func reportBtnClicked(){
        let alert = UIAlertController(title: "Report", message: "Do you want to report this post?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive,handler: { action in
            let alert = UIAlertController(title: "Reported", message: "Thank you reporting. We have received your request and we will remove this post within 12 hours if we found any issue with this post.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - Extentions
// MARK: - UITableViewDelegate
extension FeedViewController: UITableViewDelegate {}

// MARK: - UITableViewDataSource
extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return postsModel.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsModel[section].posts.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID)
        (header as? FeedHeaderTableViewCell)?.tintColor = #colorLiteral(red: 0.1137254902, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
        (header as? FeedHeaderTableViewCell)?.configure(postsModel[section].date.setupDate())
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postSection = postsModel[indexPath.section]
        let post = postSection.posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let author = post.author.name == "" ? post.author.email : post.author.name
        let time = String(post.creationTime.suffix(5))
        let isDelete = setupDeleteButton(Int(user.id), post.author.id, admin)
        let image = post.picture
        let song = post.songName
        let view = checkView(post.id)
        let link = post.link
        
        // (UIImage(url: URL(string: image)) ?? UIImage(named: "imCover"))!
        (cell as? FeedTableViewCell)?.configure(song, isDelete, link, image, author, time, post.commentsNumber, post.id, postSection.date, post.author.id, view, post.author.name)
        (cell as? FeedTableViewCell)?.delegate = self
        (cell as? FeedTableViewCell)?.setNeedsLayout()
        
        if let cell = cell as?  FeedTableViewCell {
            cell.report.isUserInteractionEnabled = true
            cell.report.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportBtnClicked)))
        }
        
       //        coreDataManager.addPost(postsModel[indexPath.section].posts[indexPath.row].id, author, link, song, postsModel[indexPath.section].date + " " + time, image, postsModel[indexPath.section].posts[indexPath.row].commentsNumber)
              return cell
    }
}

// MARK: - FeedVCProtocol
extension FeedViewController: FeedVCProtocol {
    
    func moveToUserProfile(button: UIButton, id: Int) {
        userId = id
        checkConnection()
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                performSegue(withIdentifier: "toUserProfileSegue", sender: nil)
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
    
    func moveToComments(button: UIButton, id: Int, date: String, name: String) {
        datePost = date.setupDate()
        postId = id
        checkConnection()
        commentsTitle = "Post \(name)"
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                performSegue(withIdentifier: "toCommentsSegue", sender: nil)
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
    
    func moveToPlayer(button: UIButton, id: Int, image: UIImage) {
        let link = button.titleLabel?.text ?? ""
        postId = id
        videoId = getIdVideo(link)
        let appleId = getAppleMusicTrackId(link)
        let array : Array = [appleId]
        appleMusicTrackId = array
        spotifyId = getSpotifyId(link)
        spotifyImage = image
        checkConnection()
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                if link.contains("music.apple.com") {
                    appleMusicRequestPermission()
                }
                if link.contains("youtube.com") || link.contains("youtu.be") {
                    performSegue(withIdentifier: "toPlayerSegue", sender: nil)
                }
                if link.contains("open.spotify.com") {
                    performSegue(withIdentifier: "toSpotifySegue", sender: nil)
                }
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
    
    func deletePosts(button: UIButton, id: Int) {
        checkConnection()
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                showAlertWithDelete(id)
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
}
