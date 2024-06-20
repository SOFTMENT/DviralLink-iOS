//
//  MenuViewController.swift
//  DropIt
//
//

import Lottie
import UIKit
import youtube_ios_player_helper

class YouTubeViewController: UIViewController {

    @IBOutlet private var toFeedButton: UIButton!
    @IBOutlet private var animationView: AnimationView!
    @IBOutlet weak private var playButton: UIButton!
    @IBOutlet private var playerViewContainer: YTPlayerView!
    @IBOutlet weak private var muteButton: UIButton!
    @IBOutlet private weak var viewsLabel: UILabel!
    
    private var count = FirstTimeListenLimit.timeToWait
    private var timer = Timer()
    private var videoId = ""
    private var postId = 0
    private let moyaManager = MoyaManager()
    private let coreDataManager = CoreDataManager()
    private var userId = 0
    
    func setVideoId(_ videoId: String) {
        self.videoId = videoId
    }
    
    func setPostId(_ postId: Int) {
        self.postId = postId
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideo()
        playerViewContainer.delegate = self
        checkFirstTimeView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        userId = Int(coreDataManager.getUser().id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stopTimer()
        playerViewContainer.stopVideo()
    }
    
    // MARK: - Setup
    private func setupLabel() {
        if coreDataManager.getUser().admin {
            viewsLabel.isHidden = true
        } else {
            viewsLabel.isHidden = false
            getViews(Int(coreDataManager.getUser().id))
        }
    }
    
    // MARK: - Logic
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playButton.alpha == 0 {
            playButton.alpha = 1
        } else {
            playButton.alpha = 0
        }
    }
    
    private func loadVideo() {
         let playerVars:[String: Any] = [
            "controls" : "0",
            "showinfo" : "1",
            "autoplay": "1",
            "rel": "0",
            "modestbranding": "1",
            "iv_load_policy" : "3",
            "fs": "0",
            "playsinline" : "1"
        ]
       _ = playerViewContainer.load(withVideoId: videoId, playerVars: playerVars)
        playerViewContainer.isUserInteractionEnabled = false
        startTimer()
        startAnimation()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.count -= 1
            print("\(self.count)")
            if self.count == 0 {
                self.stopTimer()
                self.checkView()
            }
        })
    }
    
    private func startAnimation() {
        animationView.play()
        animationView.animationSpeed = 0.5
    }
    
    private func stopAnimation() {
        animationView.pause()
    }
    
    private func checkView () {
        if coreDataManager.checkView(userId, postId) {
            print("none")
        } else {
            addViews()
            coreDataManager.addView(userId, postId, getDate())
            toFeedButton.alpha = 1
            animationView.alpha = 0
            getViews(userId)
        }
    }
    
    private func checkFirstTimeView() {
        userId = Int(coreDataManager.getUser().id)
        if coreDataManager.checkView(userId, postId) || coreDataManager.getUser().admin {
            animationView.alpha = 0
        } else {
            toFeedButton.alpha = 0
        }
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    // MARK: - API Calls
    private func addViews() {
        let date = getDate()
        moyaManager.requestUsersView { (responseCode) in
            switch responseCode {
            case 200:
                self.coreDataManager.addView(self.userId, self.postId, date)
                print("Successfully incremented views")
            case 401:
                print("User not found")
            default:
                print("Error")
            }
        }
    }
    
    private func getViews(_ id: Int) {
        moyaManager.requestGetViews(id) { (responseCode, responseMessage) in
            switch responseCode {
            case 200:
                self.viewsLabel.text = "You have viewed \(responseMessage) posts"
                if responseMessage == "5" {
                    self.showAlert("Congratulations 😀\n You've viewed 5 posts!!! ", "YOU CAN POST NOW")
                }
            default:
                print("Vse ploho")
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func tappedPlay(_ sender: Any) {
        playButton.isSelected = !playButton.isSelected
        if playButton.isSelected {
            playerViewContainer.pauseVideo()
            stopTimer()
            stopAnimation()
        } else {
            playerViewContainer.playVideo()
            startTimer()
            startAnimation()
        }
    }    
    @IBAction private func tappedGoToFeed(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
}

// MARK: - Extentions
// MARK: - YTPlayerViewDelegate
extension YouTubeViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.playerViewContainer.playVideo()
    }
}
