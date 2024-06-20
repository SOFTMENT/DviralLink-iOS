//
//  WelcomeViewController.swift
//  DropIt
//
//  Created by Apple on 21/09/22.
//

import UIKit
import TTGSnackbar
import AudioToolbox
import FirebaseFirestore
import FirebaseAuth

class WelcomeViewController : UIViewController {
    
    @IBOutlet var mView: UIView!
    
    @IBOutlet weak var fullView: UIImageView!
    
    @IBOutlet weak var theHUB1: UIView!
    @IBOutlet weak var theHUB2: UIView!
    
    @IBOutlet weak var bookBtn1: UIView!
    @IBOutlet weak var bookBtn2: UIView!
    @IBOutlet weak var bookBtn3: UIView!
    @IBOutlet weak var bookBtn4: UIView!
    @IBOutlet weak var bookBtn5: UIView!
    @IBOutlet weak var bookBtn6: UIView!
    
    
    
    override func viewDidLoad() {
        
    
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }
       

      
  
      

        var date = DateComponents()
        date.year = 2022
        date.month = 09
        date.day = 28
        date.timeZone = TimeZone(abbreviation: "IST")
        date.hour = 8
        date.minute = 59
        date.second = 55
        let userCalendar = Calendar.current

        let currentDate = Date()
        if let futureDateAndTime = userCalendar.date(from: date) {
            if futureDateAndTime > currentDate {
                self.performSegue(withIdentifier: "toFeedSeg", sender: nil)

            }
            else {
                self.mView.isHidden = false
            }
        }
        
        
        setupImageTitle()
        
        
        
        fullView.isUserInteractionEnabled = true
        fullView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fullViewClicked)))
        
        theHUB1.isUserInteractionEnabled = true
        theHUB2.isUserInteractionEnabled = true
        theHUB1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hubClicked)))
        theHUB2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hubClicked)))
        
        bookBtn1.isUserInteractionEnabled = true
        bookBtn2.isUserInteractionEnabled = true
        bookBtn3.isUserInteractionEnabled = true
        bookBtn4.isUserInteractionEnabled = true
        bookBtn5.isUserInteractionEnabled = true
        bookBtn6.isUserInteractionEnabled = true
        
        bookBtn1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookAppointmentBtnClicked)))
        
        bookBtn2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookAppointmentBtnClicked)))
        
        bookBtn3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookAppointmentBtnClicked)))
        
        bookBtn4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookAppointmentBtnClicked)))
        
        bookBtn5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookAppointmentBtnClicked)))
        
        bookBtn6.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookAppointmentBtnClicked)))
        
    }
    
    
    @IBAction func menuBtnTapped(_ sender: Any) {
       
        self.performSegue(withIdentifier: "menuSeg", sender: nil)
        
    }
        
    @objc func bookAppointmentBtnClicked(){
        
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), {
            
        })
 
        if CoreDataManager().getUser().email == "iamvijay67@gmail.com" || CoreDataManager().getUser().email == "fitzentrepreneur@gmail.com" {
            let alert = UIAlertController(title: "Select", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "User", style: .default,handler: { action in
                self.performSegue(withIdentifier: "userBookSeg", sender: nil)
            }))
            alert.addAction(UIAlertAction(title: "Admin", style: .default, handler: { action in
                self.performSegue(withIdentifier: "adminbookNowSeg", sender: nil)
            }))
            present(alert, animated: true)
        }
        else {
            self.performSegue(withIdentifier: "userBookSeg", sender: nil)
        }
        
        
                                                  
    }

    @objc func hubClicked(){
      
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), {
            
        })
        
        self.performSegue(withIdentifier: "toFeedSeg", sender: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupImageTitle() {
        let image = UIImage(named: "icLogo.png")
        let imageView = UIImageView(image: image)
        imageView.widthAnchor.constraint(equalToConstant: 62).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 43).isActive = true
        self.navigationItem.titleView = imageView
    }
    
    @objc func fullViewClicked(){
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), {
            
        })
        self.showSnack(messages: "Coming Soon...")
    }
    
    func showSnack(messages : String) {
        
        
        let snackbar = TTGSnackbar(message: messages, duration: .long)
        snackbar.messageLabel.textAlignment = .center
        snackbar.show()
    }
    
    
}

