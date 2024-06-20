import Lottie
import MediaPlayer
import StoreKit
import UIKit

class AppleMusicViewController: UIViewController {
    
    @IBOutlet private var toFeedButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private weak var viewsLabel: UILabel!
    @IBOutlet private var animationView: AnimationView!
    
    private var count = FirstTimeListenLimit.timeToWait
    private var timer = Timer()
    private var appleMusicTrackId = [""]
    private let deletedSymbol = "="
    private var postId = 0
    private var userId = 0
    private let moyaManager = MoyaManager()
    private let coreDataManager = CoreDataManager()
    private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startPlayTrack()
        checkFirstTimeView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        musicPlayer.stop()
        stopTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        userId = Int(coreDataManager.getUser().id)
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
    func setPostId(_ postId: Int) {
        self.postId = postId
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playButton.alpha == 0 {
            playButton.alpha = 1
        } else {
            playButton.alpha = 0
        }
    }
    private func startAnimation() {
        animationView.play()
        animationView.animationSpeed = 0.5
    }
    
    private func stopAnimation() {
        animationView.pause()
    }
    
    private func modifyTrackId() {
        if appleMusicTrackId[0].contains(deletedSymbol) {
            appleMusicTrackId[0].removeFirst()
            print(appleMusicTrackId)
        }
    }
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.count -= 1
            print(self.count)
            if self.count == 0 {
                self.stopTimer()
                self.checkView()
            }
        })
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
    
    private func appleMusicRequestPermission() {
         SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
             switch status {
             case .authorized:
                self.modifyTrackId()
                self.musicPlayer.setQueue(with: self.appleMusicTrackId)
                self.musicPlayer.play()
                self.startTimer()
                self.startAnimation()
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
   
     func setAppleMusicTrackId(_ appleMusicTrackId: [String]) {
           self.appleMusicTrackId = appleMusicTrackId
    }
    
   private func startPlayTrack() {
        appleMusicRequestPermission()
      
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
    @IBAction private func tappedPlayButton(_ sender: Any) {
        playButton.isSelected = !playButton.isSelected
        if playButton.isSelected {
            musicPlayer.pause()
            stopTimer()
            stopAnimation()
        } else {
            musicPlayer.play()
            startTimer()
            startAnimation()
        }
    }
    @IBAction private func tappedToFeedButton(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
}
