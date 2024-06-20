//
//  CommentsViewController.swift
//  DropIt
//
//

import UIKit

class CommentsViewController: BaseViewController {
    
    @IBOutlet private weak var commentView: UIView!
    @IBOutlet weak private var postTableView: UITableView!
    @IBOutlet private weak var commentTextField: UITextField!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let headerID = "FeedHeaderTableViewCell"
    private let headerIDComments = "CommentsHeaderTableViewCell"
    private var date = ""
    private var postId = 0
    private var videoId = ""
    private var id = 0
    private var postModel = PostModel()
    private var commentsModel: [CommentModel] = []
    private let moyaManager = MoyaManager()
    private var coreDataManager = CoreDataManager()
    private var user = User()
    private var isDelete = false
    private var userId = 0
    private var timer: Timer!
    private var commentsTitle = ""
    private let refreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getPost()
        getUser()
        getComments(false)
//        updateTable()
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
        commentTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationItem.title = commentsTitle
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundView(commentView)
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Setup
    private func setupRole(_ idAuthor: Int, _ admin: Bool, _ id: Int) -> Bool {
        print(" Post -> \(idAuthor), \(admin), \(id)")
        if id == idAuthor {
            return true
        }
        if admin {
            return true
        }
        return false
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
    
    private func setupTableView() {
        let nib = UINib(nibName: headerID, bundle: nil)
        postTableView.register(nib, forHeaderFooterViewReuseIdentifier: headerID)
        let nibComment = UINib(nibName: headerIDComments, bundle: nil)
        postTableView.register(nibComment, forHeaderFooterViewReuseIdentifier: headerIDComments)
        postTableView.register(UINib(nibName: "MainCommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "MainCommentsTableViewCell")
        postTableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentsTableViewCell")
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.refreshControl = refreshControl
    }
    
    private func setupTimeInCell(date: String) -> String {
        let time = date.suffix(5)
        let day = date.prefix(10).suffix(2)
        let month = date.prefix(10)[date.prefix(10).index(date.prefix(10).startIndex, offsetBy: 5)..<date.prefix(10).index(date.prefix(10).endIndex, offsetBy: -3)]
        let year = date.prefix(10).prefix(4)
        return "\(day).\(month).\(year)".setupDate() + " at " + time
    }
    
    func setDate(_ date: String) { // logic
        self.date = date
    }
    
    func setPost(_ id: Int) {
        self.postId = id
    }
    
    func setTitle(_ title: String) {
        self.commentsTitle = title
        print(self.commentsTitle)
    }
    
    private func getUser() {
        user = coreDataManager.getUser()
        id = Int(user.id)
//        ApiConstants.token = user.token ?? ""
//        print(ApiConstants.token)
    }
    
    // MARK: - API Calls
    private func getPost() {
        moyaManager.requestGetPost(postId, completion: { /*[weak self]*/ (responseCode, responseModel) in
            switch responseCode {
            case 200:
                self.postModel = responseModel
                self.postTableView.reloadData()
                self.postTableView.isHidden = false
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            case 404:
                print("No Post")
            default:
                print("Error")
            }
        })
    }
    
    private func getComments(_ bool: Bool) {
        moyaManager.requestGetComments(postId) { (responseCode, responseModel) in
            switch responseCode {
            case 200:
                self.commentsModel = responseModel
                self.postTableView.reloadData()
                switch bool {
                case true:
                    self.autoScroll()
                case false: break
                }
            default:
                print("Error")
            }
        }
    }
    
    private func deleteComment(_ id: Int) {
        moyaManager.requestDeleteComment(id) { (responseCode) in
            switch responseCode {
            case 200:
                print("Deleted comment -> \(id)")
                self.getComments(false)
            case 403:
                print("User trying to delete a comment of other user not being an author of this post.")
            default:
                print("Error")
            }
        }
    }
    
    private func createComment() {
        moyaManager.requestCreateComments(postId, Int(user.id), commentTextField.text ?? "") { (responseCode, _) in
            switch responseCode {
            case 201:
                self.commentTextField.text = ""
                self.getComments(true)
            default:
                print("Error")
            }
        }
    }
    
    // MARK: - Logic
    private func updateTable() {
        self.timer = Timer(timeInterval: 180.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer, forMode: .default)
    }
    
    @objc func refreshTable(_ sender: AnyObject) {
        getPost()
        getComments(false)
        self.postTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    @objc
    func refresh() {
        getPost()
        getComments(false)
    }
    
    private func autoScroll() {
        self.postTableView.reloadData()
        print(commentsModel.count-1)
        self.postTableView.scrollToRow(at: IndexPath(row: self.commentsModel.count-1, section: 1), at: .top, animated: true)
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
    
    private func showAlertWithDelete (_ id: Int) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let attributedText = NSAttributedString(string: "This Comment Will Be Deleted For Everyone", attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.white ])
        let attributedTitle = NSAttributedString(string: "Are You Sure You Want To Delete This Comment?", attributes: [ NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.white] )
        alert.setValue(attributedText, forKey: "attributedMessage")
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.view.subviews[0].subviews[0].subviews[0].backgroundColor = .init(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.90)
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .default) {_ in
            self.deleteComment(id)
        }
        alert.addAction(deleteAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {_ in}
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toAuthorSegue":
            guard let destinationVC = segue.destination as? UINavigationController else { return }
            if let profileVC = destinationVC.viewControllers[0] as? ProfileViewController {
                profileVC.setUserId(userId)
            }
        case "toYoutubePlayer":
            guard let destinationVC = segue.destination as? YouTubeViewController else { return }
            destinationVC.setVideoId(videoId)
        default: break
        }
    }

    // MARK: - Actions
    @IBAction private func tappedSendComment(_ sender: UIButton) {
        commentTextField.resignFirstResponder()
        if commentTextField.text == "" {
            showAlert("Your Comment Is Empty", "Please Write Your Comment")
        } else {
            createComment()
        }
    }
}

// MARK: - Extentions
// MARK: - UITableViewDelegate, UITableViewDataSource
extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerID)
            (header as? FeedHeaderTableViewCell)?.tintColor = #colorLiteral(red: 0.1134289578, green: 0.1134518012, blue: 0.1134239659, alpha: 1)
            (header as? FeedHeaderTableViewCell)?.configure(date)
            return header
        } else {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIDComments)
            (header as? CommentsHeaderTableViewCell)?.tintColor = #colorLiteral(red: 0.1134289578, green: 0.1134518012, blue: 0.1134239659, alpha: 1)
            (header as? CommentsHeaderTableViewCell)?.configure(commentsModel.count)
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 44
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if commentsModel.count == 0 {
                return 1
            } else {
                return commentsModel.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MainCommentsTableViewCell", for: indexPath)
            print(postModel)
            let author = postModel.author.name == "" ? postModel.author.email : postModel.author.name
            let image = postModel.picture
            let song = postModel.songName
        
            (cell as? MainCommentsTableViewCell)?.configure(song: song, link: postModel.link, image: (UIImage(contentsOfFile: image) ?? UIImage(named: "imCover"))!, author: author, time: String(postModel.creationTime.suffix(5)), idUser: postModel.author.id)
            (cell as? MainCommentsTableViewCell)?.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell", for: indexPath)
            if commentsModel.isEmpty {
                (cell as? CommentsTableViewCell)?.configure(id: 0, comment: "", delete: false, author: "Please leave your comment below", time: "", idAuthor: 0, owner: false)
            } else {
                let isOwner = commentsModel[indexPath.row].userId == postModel.author.id ? true : false
                let isDelete = setupDeleteButton(Int(user.id), commentsModel[indexPath.row].userId, user.admin)
                (cell as? CommentsTableViewCell)?.configure(id: commentsModel[indexPath.row].id, comment: commentsModel[indexPath.row].text, delete: isDelete, author: commentsModel[indexPath.row].userName, time: setupTimeInCell(date: commentsModel[indexPath.row].creationTime), idAuthor: commentsModel[indexPath.row].userId, owner: isOwner)
            }
            (cell as? CommentsTableViewCell)?.delegate = self
            return cell
        }
    }
}

// MARK: - CommentsVCProtocol
extension CommentsViewController: CommentsVCProtocol {
    func deleteComment(button: UIButton, id: Int) {
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
    
    func moveToPlayer(button: UIButton) {
        let link = button.titleLabel?.text ?? ""
        videoId = getIdVideo(link)
        checkConnection()
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                if link.contains("music.apple.com") {
                    performSegue(withIdentifier: "toAppleMusicSegue", sender: nil)
                }
                if link.contains("youtube.com") || link.contains("youtu.be") {
                    performSegue(withIdentifier: "toYoutubePlayer", sender: nil)
                }
                if link.contains("spotify.com") {
                    performSegue(withIdentifier: "toSpotifySegue", sender: nil)
                }
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
    
    func moveToUserProfile(button: UIButton, id: Int) {
        userId = id
        checkConnection()
        if let connection = reachability?.connection {
            switch connection {
            case .wifi, .cellular:
                performSegue(withIdentifier: "toAuthorSegue", sender: nil)
            case .none, .unavailable:
                showAlert("No Connection","Anable to connect, please check your internet connection.")
            }
        }
    }
}
