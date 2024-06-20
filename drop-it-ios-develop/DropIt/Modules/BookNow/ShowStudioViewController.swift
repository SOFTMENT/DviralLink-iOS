//
//  ShowStudioViewController.swift
//  DropIt
//
//  Created by Vijay Rathore on 17/10/22.
//

import UIKit
import Stripe
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FSCalendar


class ShowStudioViewController : UIViewController {
    let userNotificationCenter = UNUserNotificationCenter.current()
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    
    @IBOutlet weak var mName: UILabel!
    
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mAddress: UILabel!

    
    let datePicker = UIDatePicker()
    var totalCost = 50
    var paymentSheet: PaymentSheet?
    var studio : StudioModel?
    var orderId = ""
    var selectedHours = [Int]()
    
    @IBOutlet weak var fullNameET: UITextField!
    @IBOutlet weak var phoneNumberET: UITextField!
    
    
    @IBOutlet weak var availableOnDate: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var morningView: UIView!
    @IBOutlet weak var afternoonView: UIView!
    @IBOutlet weak var eveningView: UIView!
    
    @IBOutlet weak var m12_00am: UIButton!
    @IBOutlet weak var m12_30am: UIButton!
    
    @IBOutlet weak var m01_00am: UIButton!
    @IBOutlet weak var m01_30am: UIButton!
    
    @IBOutlet weak var m02_00am: UIButton!
    @IBOutlet weak var m02_30am: UIButton!
    
    @IBOutlet weak var m03_00am: UIButton!
    @IBOutlet weak var m03_30am: UIButton!
    
    @IBOutlet weak var m04_00am: UIButton!
    @IBOutlet weak var m04_30am: UIButton!
    
    @IBOutlet weak var m05_00am: UIButton!
    @IBOutlet weak var m05_30am: UIButton!
    
    @IBOutlet weak var m06_00am: UIButton!
    @IBOutlet weak var m06_30am: UIButton!
    
    @IBOutlet weak var m07_00am: UIButton!
    @IBOutlet weak var m07_30am: UIButton!
    
    @IBOutlet weak var m08_00am: UIButton!
    @IBOutlet weak var m08_30am: UIButton!
    
    @IBOutlet weak var m09_00am: UIButton!
    @IBOutlet weak var m09_30am: UIButton!
    
    @IBOutlet weak var m10_00am: UIButton!
    @IBOutlet weak var m10_30am: UIButton!
    
    @IBOutlet weak var m11_00am: UIButton!
    @IBOutlet weak var m11_30am: UIButton!
    
    @IBOutlet weak var m12_00pm: UIButton!
    @IBOutlet weak var m12_30pm: UIButton!
    
    @IBOutlet weak var m01_00pm: UIButton!
    @IBOutlet weak var m01_30pm: UIButton!
    
    @IBOutlet weak var m02_00pm: UIButton!
    @IBOutlet weak var m02_30pm: UIButton!
    
    @IBOutlet weak var m03_00pm: UIButton!
    @IBOutlet weak var m03_30pm: UIButton!
    
    @IBOutlet weak var m04_00pm: UIButton!
    @IBOutlet weak var m04_30pm: UIButton!
    
    @IBOutlet weak var m05_00pm: UIButton!
    @IBOutlet weak var m05_30pm: UIButton!
    
    @IBOutlet weak var m06_00pm: UIButton!
    @IBOutlet weak var m06_30pm: UIButton!
    
    @IBOutlet weak var m07_00pm: UIButton!
    @IBOutlet weak var m07_30pm: UIButton!
    
    @IBOutlet weak var m08_00pm: UIButton!
    @IBOutlet weak var m08_30pm: UIButton!
    
    @IBOutlet weak var m09_00pm: UIButton!
    @IBOutlet weak var m09_30pm: UIButton!
    
    @IBOutlet weak var m10_00pm: UIButton!
    @IBOutlet weak var m10_30pm: UIButton!
    
    @IBOutlet weak var m11_00pm: UIButton!
    @IBOutlet weak var m11_30pm: UIButton!
    var totaltime : Int = 1
    var selectedDate = Date()
    override func viewDidLoad() {
        
        guard let studio = studio else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            
            return
        }
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        
        mImage.layer.cornerRadius = 8
        
        if let imagePath = studio.image, !imagePath.isEmpty {
            self.mImage.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage(named: "placeholder"))
        }
        
        mName.text = studio.name ?? ""
        mAddress.text = studio.address ?? ""
        mPrice.text = "\(studio.price ?? 0)$ hour"
        
       
        calendar.delegate = self
        calendar.dataSource = self
        
        
        morningView.layer.cornerRadius = 8
        afternoonView.layer.cornerRadius = 8
        eveningView.layer.cornerRadius = 8
        
        
        
        getAppointment(dateString: self.convertDateForAppointment(Date()))
        
    }
    
  
    func getAppointment(dateString : String){
        progressHUDShow(text: "Loading...")
        Firestore.firestore().collection("Appointments").whereField("appointmentDateString", isEqualTo: dateString).getDocuments { snapshot, error in
            self.progressHUDHide()
            if let error = error {
                self.showMyError(error.localizedDescription)
            }
            else {
                self.refreshUI()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let appointment = try? qdr.data(as: AppointmentModel.self) {
                           
                            self.setTimeUI(selectedHours: appointment.selectedHours)
                        }
                    }
                }
                
            }
        }
    }
    
    
    
    @objc func backBtnClicked() {
        self.dismiss(animated: true)
    }
    
    func nextClicked(startTime : String, startNumber : Int) {
        selectedHours.removeAll()
        
        if fullNameET.text == "" {
            self.showToast(message: "Enter Full Name")
            return
        }
        else if phoneNumberET.text == "" {
            self.showToast(message: "Enter Phone Number")
            return
        }
        
        let numbers = totaltime * 2
        for y in 0..<(numbers) {
            
            self.selectedHours.append(startNumber+y)
        }
        
        
        self.progressHUDShow(text: "")
        initalizePaymentData(amount: String(self.totalCost * totaltime), currency: "usd", description: "DViral Appointment", email: CoreDataManager().getUser().email ?? "support@softment.in") { isSuccess, errorMessage  in
            if isSuccess {
                let appointment = AppointmentModel()
                appointment.id  = Firestore.firestore().collection("Appointments").document().documentID
                appointment.phoneNumber = self.phoneNumberET.text ?? "123456789"
                appointment.appointmentDate = self.selectedDate
                appointment.appointmentStarTime = startTime
                appointment.appointmentHour = self.totaltime
                appointment.studioName = self.studio!.name ?? "Studio Name"
                appointment.userEmail = CoreDataManager().getUser().email ?? "support@softment.in"
                appointment.orderID = self.orderId
                appointment.orderTime = Date()
                appointment.studioId = self.studio!.id ?? ""
                appointment.userName = self.fullNameET.text ?? "Full Name"
                appointment.appointmentDateString = self.convertDateForAppointment(self.selectedDate)
                appointment.selectedHours = self.selectedHours
                appointment.status = "Pending"
                try? Firestore.firestore().collection("Appointments").document(appointment.id!).setData(from: appointment,completion: { error in
                    self.progressHUDHide()
                    if let error = error {
                        self.showMyError(error.localizedDescription)
                    }
                    else {
                        
                        self.sendMail(to_name: CoreDataManager().getUser().name ?? "Dviral Link", to_email: CoreDataManager().getUser().email ?? "iamvijay67@gmail.com", subject: "Appointment Successful", body: "Thank you for your appointment. We have received your request and we will contact you soon. Thank You")
                        self.sendNotification()
                        let alert  = UIAlertController(title: "BOOKED!", message: "Thank you for booking appointment, We have received your request and we will send infomation about appointment on your mail address.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { action in
                            self.performSegue(withIdentifier: "welcomeSeg", sender: nil)
                        }))
                        
                        self.present(alert, animated: true)
                    }
                })
                
            }
            else {
                DispatchQueue.main.async {
                    self.progressHUDHide()
                    if errorMessage != "" {
                        self.showMyError(errorMessage)
                    }
                  
                }
                
            }
            
        }
        
        
    }
    
    public func refreshUI(){
        resetButton(value: m12_00am)
        resetButton(value: m12_30am)
        resetButton(value: m01_00am)
        resetButton(value: m01_30am)
        resetButton(value: m02_00am)
        resetButton(value: m02_30am)
        resetButton(value: m03_00am)
        resetButton(value: m03_30am)
        resetButton(value: m04_00am)
        resetButton(value: m04_30am)
        resetButton(value: m05_00am)
        resetButton(value: m05_30am)
        resetButton(value: m06_00am)
        resetButton(value: m06_30am)
        resetButton(value: m07_00am)
        resetButton(value: m07_30am)
        resetButton(value: m08_00am)
        resetButton(value: m08_30am)
        resetButton(value: m09_00am)
        resetButton(value: m09_30am)
        resetButton(value: m10_00am)
        resetButton(value: m10_30am)
        resetButton(value: m11_00am)
        resetButton(value: m11_30am)
        resetButton(value: m12_00pm)
        resetButton(value: m12_30pm)
        resetButton(value: m01_00pm)
        resetButton(value: m01_30pm)
        resetButton(value: m02_00pm)
        resetButton(value: m02_30pm)
        resetButton(value: m03_00pm)
        resetButton(value: m03_30pm)
        resetButton(value: m04_00pm)
        resetButton(value: m04_30pm)
        resetButton(value: m05_00pm)
        resetButton(value: m05_30pm)
        resetButton(value: m06_00pm)
        resetButton(value: m06_30pm)
        resetButton(value: m07_00pm)
        resetButton(value: m07_30pm)
        resetButton(value: m08_00pm)
        resetButton(value: m08_30pm)
        resetButton(value: m09_00pm)
        resetButton(value: m09_30pm)
        resetButton(value: m10_00pm)
        resetButton(value: m10_30pm)
        resetButton(value: m11_00pm)
        resetButton(value: m11_30pm)
        
        
    }
    
    public func resetButton(value : UIButton) {
        value.setTitleColor(.white, for: .normal)
        value.isEnabled = true
        value.layer.cornerRadius = 8
        value.isUserInteractionEnabled = true
        value.isEnabled = true
        value.backgroundColor = UIColor(red: 197/255, green: 41/255, blue: 47/255, alpha: 1)
    }
    
    public func setTimeUI(selectedHours : [Int]?) {
        
        
        
        guard let selectedHours = selectedHours else {
            return
        }
        
        for x in 0..<(selectedHours.count) {
            var btn : UIButton?
            switch selectedHours[x] {
            case 0: btn = self.m12_00am
                break
            case 1: btn = self.m12_30am
                break
            case 2: btn = self.m01_00am
                break
            case 3: btn = self.m01_30am
                break
            case 4: btn = self.m02_00am
                break
            case 5: btn = self.m02_30am
                break
            case 6: btn = self.m03_00am
                break
            case 7: btn = self.m03_30am
                break
            case 8: btn = self.m04_00am
                break
            case 9: btn = self.m04_30am
                break
            case 10: btn = self.m05_00am
                break
            case 11: btn = self.m05_30am
                break
            case 12: btn = self.m06_00am
                break
            case 13: btn = self.m06_30am
                break
            case 14: btn = self.m07_00am
                break
            case 15: btn = self.m07_30am
                break
            case 16: btn = self.m08_00am
                break
            case 18: btn = self.m09_00am
                break
            case 19: btn = self.m09_30am
                break
            case 20: btn = self.m10_00am
                break
            case 21: btn = self.m10_30am
                break
            case 22: btn = self.m11_00am
                break
            case 23: btn = self.m11_30am
                break
            case 24: btn = self.m12_00pm
                break
            case 25: btn = self.m12_30pm
                break
            case 26: btn = self.m01_00pm
                break
            case 27: btn = self.m01_30pm
                break
            case 28: btn = self.m02_00pm
                break
            case 29: btn = self.m02_30pm
                break
            case 30: btn = self.m03_00pm
                break
            case 31: btn = self.m03_30pm
                break
            case 32: btn = self.m04_00pm
                break
            case 33: btn = self.m04_30pm
                break
            case 34: btn = self.m05_00pm
                break
            case 35: btn = self.m05_30pm
                break
            case 36: btn = self.m06_00pm
                break
            case 37: btn = self.m06_30pm
                break
            case 38: btn = self.m07_00pm
                break
            case 39: btn = self.m07_30pm
                break
            case 40: btn = self.m08_00pm
                break
            case 41: btn = self.m08_30pm
                break
            case 42: btn = self.m09_00pm
                break
            case 43: btn = self.m09_30pm
                break
            case 44: btn = self.m10_00pm
                break
            case 45: btn = self.m10_30pm
                break
            case 46: btn = self.m11_00pm
                break
            case 47: btn = self.m11_30pm
                break
                
                
            default : print("NULL")
                
            }
            
            if let btn = btn {
                btn.backgroundColor = UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1)
                btn.setTitleColor(.white, for: .normal)
                btn.layer.cornerRadius = 8
                btn.isUserInteractionEnabled = false
                btn.isEnabled = false
            }
            
        }
        
    }
    
    
    
    @IBAction func m12_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "12:00 am",startNumber: 0)
        
        
    }
    @IBAction func m12_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "12:30 am",startNumber: 1)
        
        
    }
    
    @IBAction func m01_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "01:00 am",startNumber: 2)
        
        
    }
    
    @IBAction func m01_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "01:30 am",startNumber: 3)
        
        
    }
    
    @IBAction func m02_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "02:00 am",startNumber: 4)
        
        
    }
    @IBAction func m02_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "02:30 am",startNumber: 5)
        
        
    }
    @IBAction func m03_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "03:00 am",startNumber: 6)
        
        
    }
    @IBAction func m03_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "03:30 am",startNumber: 7)
        
        
    }
    @IBAction func m04_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "04:00 am",startNumber: 8)
        
        
    }
    @IBAction func m04_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "04:30 am",startNumber: 9)
        
        
    }
    @IBAction func m05_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "05:00 am",startNumber: 10)
        
        
    }
    @IBAction func m05_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "05:30 am",startNumber: 11)
        
        
    }
    @IBAction func m06_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "06:00 am",startNumber: 12)
        
        
    }
    @IBAction func m06_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "06:30 am",startNumber: 13)
        
        
    }
    @IBAction func m07_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "07:00 am",startNumber: 14)
        
        
    }
    @IBAction func m07_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "07:30 am",startNumber: 15)
        
        
    }
    @IBAction func m08_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "08:00 am",startNumber: 16)
        
        
    }
    @IBAction func m08_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "08:30 am",startNumber: 17)
        
        
    }
    @IBAction func m09_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "09:00 am",startNumber: 18)
        
        
    }
    @IBAction func m09_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "09:30 am",startNumber: 19)
        
        
    }
    @IBAction func m10_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "10:00 am",startNumber: 20)
        
        
    }
    @IBAction func m10_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "10:30 am",startNumber: 21)
        
        
    }
    @IBAction func m11_00amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "11:00 am",startNumber: 22)
        
        
    }
    @IBAction func m11_30amClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "11:30 am",startNumber: 23)
        
        
    }
    @IBAction func m12_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "12:00 pm",startNumber: 24)
        
        
    }
    
    @IBAction func m12_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "12:30 pm",startNumber: 25)
        
        
    }
    
    @IBAction func m01_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "01:00 pm",startNumber: 26)
        
        
    }
    
    @IBAction func m01_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "01:30 pm",startNumber: 27)
        
        
    }
    @IBAction func m02_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "02:00 pm",startNumber: 28)
        
        
    }
    @IBAction func m02_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "02:30 pm",startNumber: 29)
        
        
    }
    @IBAction func m03_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "03:00 pm",startNumber: 30)
        
        
    }
    @IBAction func m03_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "03:30 pm",startNumber: 31)
        
        
    }
    @IBAction func m04_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "04:00 pm",startNumber: 32)
        
        
    }
    @IBAction func m04_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "04:30 pm",startNumber: 33)
        
        
    }
    @IBAction func m05_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "05:00 pm",startNumber: 34)
        
        
    }
    @IBAction func m05_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "05:30 pm",startNumber: 35)
        
        
    }
    @IBAction func m06_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "06:00 pm",startNumber: 36)
        
        
    }
    @IBAction func m06_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "06:30 pm",startNumber: 37)
        
        
    }
    @IBAction func m07_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "07:00 pm",startNumber: 38)
        
        
    }
    @IBAction func m07_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "07:30 pm",startNumber: 39)
        
        
    }
    @IBAction func m08_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "08:00 pm",startNumber: 40)
        
        
    }
    @IBAction func m08_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "08:30 pm",startNumber: 41)
        
        
    }
    @IBAction func m09_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "09:00 pm",startNumber: 42)
        
        
    }
    @IBAction func m09_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "09:30 pm",startNumber: 43)
        
        
    }
    @IBAction func m10_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "10:00 pm",startNumber: 44)
        
        
    }
    @IBAction func m10_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "10:30 pm",startNumber: 45)
        
        
    }
    @IBAction func m11_00pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "11:00 pm",startNumber: 46)
        
        
    }
    @IBAction func m11_30pmClicked(_ sender: UIButton) {
        
        nextClicked(startTime: "11:30 pm",startNumber: 47)
        
        
    }
    
    


override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return true
}




public func initalizePaymentData(amount : String, currency : String, description : String, email : String, completion : @escaping  (Bool, String) -> Void){
    // MARK: Fetch the PaymentIntent and Customer information from the backend
    
    
    // var request = URLRequest(url: backendCheckoutUrl)
    // let parameterDictionary = ["amount" : amount, "currency" : currency]
    let headers = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    let postData = NSMutableData(data: "amount=\(amount)&currency=\(currency)&description=\(description)&email=\(email)".data(using: String.Encoding.utf8)!)
    let request = NSMutableURLRequest(url: NSURL(string: "https://softment.in/dropit/payment-intent.php" )! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.httpBody = postData as Data
    
    let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) in
        
        
        
        
        
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                
        else {
            
            
            self?.dismiss(animated: true, completion: nil)
            completion(false,"Something went wrong")
            return
        }
        
        if let paymentIntentClientSecret = json["clientSecret"] as? String,
           let orderId = json["order_id"] as? String, let self = self {
            
            
            self.orderId = orderId
            // MARK: Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Dviral Link"
            
            self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            
            DispatchQueue.main.async {
                self.paymentSheet?.present(from: self) { paymentResult in
                    
                    // MARK: Handle the payment result
                    switch paymentResult {
                        
                    case .completed:
                        
                        completion(true,"Success")
                        
                        break
                    case .canceled:
                        
                        completion(false,"")
                        break
                    case .failed(let error):
                        
                        completion(false,error.localizedDescription)
                        
                        break
                    }
                    
                }
            }
            
            
        }
        else  {
            
            if let errorMesssage = json["error"] as? String {
                completion(false,errorMesssage)
            }
            completion(false,"Something Went Wrong 2")
        }
        
        
    })
    task.resume()
}
    
    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Appointment Successful!"
        notificationContent.body = "Thank you for your appointment. We have received your request and we will contact you soon. Thank You"

        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "bookingnotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }

}

extension ShowStudioViewController : FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        
        var currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.day = -1
        currentDate = Calendar.current.date(byAdding: dateComponents, to: currentDate)!
        
        if date.compare(currentDate) == .orderedAscending {
            return false
        }
        else {
            return true
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        availableOnDate.text = "Available on \(self.convertDateFormater(date))"
        selectedDate = date
        getAppointment(dateString: self.convertDateForAppointment(selectedDate))
        
        
        
    }
    
    
}


