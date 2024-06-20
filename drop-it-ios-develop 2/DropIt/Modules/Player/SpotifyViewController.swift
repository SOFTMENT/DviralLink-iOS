//
//  SpotifyViewController.swift
//  DropIt
//
//

import Lottie
import StoreKit
import UIKit

class SpotifyViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var viewsLabel: UILabel!
    @IBOutlet private var toFeedButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var animationView: AnimationView!
    
    private var count = FirstTimeListenLimit.timeToWait
    private var timer = Timer()
    private var spotifyId = ""
    private var postId = 0
    private var userId = 0
    private let moyaManager = MoyaManager()
    private let coreDataManager = CoreDataManager()
    private var playerState: SPTAppRemotePlayerState?
    private var imageCover = UIImage()
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        userId = Int(coreDataManager.getUser().id)
        startAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageCover
        startPlaying()
        checkFirstTimeView()
        presentAlert(title: "Attention", message: "Please note that if you don't have a Spotify Premium account, you may listen to the wrong track.")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        pausePlayback()
        stopTimer()
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
    func setSpotifyId(_ spotifyId: String) {
        self.spotifyId = spotifyId
    }
    
    func setPostId(_ postId: Int) {
        self.postId = postId
    }
    
    func setSpotifyImage(_ image: UIImage) {
        self.imageCover = image
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        return {[weak self] _, error in
            if let error = error {
                print("/n LOG \(error)")
                self?.displayError(error as NSError)
            }
        }
    }
    
    var appRemote: SPTAppRemote? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote
    }
    
    private func checkView() {
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
    private func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func displayError(_ error: NSError?) {
        if error != nil {
            print("\(String(describing: error))")
        }
    }
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func startPlayback() {
        appRemote?.playerAPI?.resume(defaultCallback)
    }

    private func pausePlayback() {
        appRemote?.playerAPI?.pause(defaultCallback)
    }
    private func startPlaying() {
        appRemote?.authorizeAndPlayURI(spotifyId)
        ifSpotifyNotInstalled()
        startTimer()
    }
    private func ifSpotifyNotInstalled() {
        if appRemote?.authorizeAndPlayURI(spotifyId) == false {
            print("Install Spotify App")
            showAppStoreInstall()
        }
    }
    private func stopTimer() {
        timer.invalidate()
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
    
    private func startAnimation() {
        animationView.play()
        animationView.animationSpeed = 0.5
    }
    
    private func stopAnimation() {
        animationView.pause()
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
            pausePlayback()
            stopTimer()
            stopAnimation()
        } else {
            startPlayback()
            startTimer()
            startAnimation()
        }
    }
    @IBAction private func tappedToFeedButton(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
}
// MARK: - Extentions
// MARK: SKStoreProductViewControllerDelegate

extension SpotifyViewController: SKStoreProductViewControllerDelegate {
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            presentAlert(title: "Simulator In Use", message: "The App Store is not available in the iOS simulator, please test this feature on a physical device.")
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (_, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    self.presentAlert(
                        title: "Error accessing App Store",
                        message: error.localizedDescription)
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }
}
