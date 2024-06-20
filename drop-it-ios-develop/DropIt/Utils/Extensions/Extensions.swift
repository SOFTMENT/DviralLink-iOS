//
//  Extensions.swift
//  DropIt
//
//  Created by Vijay Rathore on 16/10/22.
//

import UIKit
import Firebase
import MBProgressHUD
import FirebaseFirestore





extension UITextView {
    
    func centerVerticalText() {
        
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    

 
    func changePlaceholderColour()  {
            attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)])
        }
        
        func addBorder() {
            layer.borderWidth = 1
            layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
            setLeftPaddingPoints(10)
            setRightPaddingPoints(10)
        }
        
}



extension Date {
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}



extension UIViewController {
    
    func createRefundRequest(paymentID : String, completion : @escaping (_ refundId : String?, _ refundStatus : String?, _ error : String?) -> Void) {
        let headers = [
                    "Content-Type": "application/x-www-form-urlencoded"
                ]

            let postData = NSMutableData(data: "paymentId=\(paymentID)".data(using: String.Encoding.utf8)!)
            let request = NSMutableURLRequest(url: NSURL(string: "https://softment.in/dropit/refund.php" )! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
           
       
            
            guard let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
            else {
                completion(nil,nil,"Invalid Response")
                  return
             }
            
            if let error = json["error"] as? String {
                completion(nil,nil,error)
                Firestore.firestore().collection("RefundERROR").document(paymentID).setData(["pi" : paymentID,"error" : error])
            }
            else {
                if let refund_id = json["refund_id"] as? String, let status = json["status"] as? String {
                    completion(refund_id, status, nil)
                }
               
            }
           

           })
           task.resume()
    
    }
    
    func sendMail(to_name : String, to_email : String, subject : String, body : String) {
        let headers = [
                    "Content-Type": "application/x-www-form-urlencoded"
                ]

            let postData = NSMutableData(data: "appName=Dviral Link&name=\(to_name)&email=\(to_email)&subject=\(subject)&body=\(body)".data(using: String.Encoding.utf8)!)
            let request = NSMutableURLRequest(url: NSURL(string: "https://softment.in/php-mailer/sendmail.php" )! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {  (data, response, error) in
           
       
            
            guard let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
            else {
              
                  return
             }
            
            if let resonse = json["response"] as? String {
                print("Email : \(resonse)")
            }
           

           })
           task.resume()
    
    }

    func generateRef() -> String {
        return  String.init(arc4random_uniform(900000) + 100000)
        
    }
    
    func progressHUDShow(text : String) {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.textColor = UIColor(red: 52/255, green: 52/255, blue: 52/255, alpha: 1)
        loading.label.font = UIFont(name: "Inter-Medium", size: 14)
    }
    
    func progressHUDHide(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 115, y: self.view.frame.size.height/2, width: 240, height: 36))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Inter-Medium", size: 14)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
  
    
  
    

    
    func sendPushNotification() {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Notification", message: "Send Notification to All Users", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Title"
        }
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Message"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines) // Force unwrapping because we know it exists.
            let textField1 = alert?.textFields![1].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if (!textField!.isEmpty && !textField1!.isEmpty) {
                PushNotificationSender().sendPushNotificationToTopic(title: textField!, body: textField1!)
                self.showToast(message: "Notification has been sent")
            }
            else {
                self.showToast(message: "Please Enter Title & Message")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
  
  
    
    

    
    func convertDateForAppointment(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "ddMMyyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateAndTimeFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy, hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "E,MMM dd,yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
  
   
    func showMessage(title : String,message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { alert in
            if title == "Thank You" {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }

    
    func showMyError(_ message : String) {
        let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
  
    
}



extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}


extension UIImageView {
    func makeRounded() {
        
        //self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
    }
    
    
    
    
}


extension UIView {
  
       func roundCorners(corners: UIRectCorner, radius: CGFloat) {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    public var safeAreaFrame: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        }
        else  {
            let window = UIApplication.shared.keyWindow
            return window!.safeAreaInsets.bottom
        }
    }
}
