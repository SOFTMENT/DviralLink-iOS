//
//  UIViewControllerExtensions.swift
//  DropIt
//
//

import AVKit
import UIKit

extension UIViewController: UITextFieldDelegate {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                let keyboardHeight = ((keyboardSize.height) > 250) ? (keyboardSize.height-45) : (keyboardSize.height-10)
                self.view.frame.origin.y = -keyboardHeight
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func isTextFieldEmpty(_ view: UIView, _ textfield: UITextField, _ errorPlaceholder: String, _ defaultPlaceholder: String) -> Bool {
        let colorError = UIColor.init(red: 215/255, green: 0/255, blue: 56/255, alpha: 1)
        if textfield.text == "" {
            view.layer.borderWidth = 1
            view.layer.borderColor = colorError.cgColor
            textfield.attributedPlaceholder = NSAttributedString(string: errorPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: colorError])
            return true
        } else {
            view.layer.borderWidth = 0
            textfield.attributedPlaceholder = NSAttributedString(string: defaultPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
        return false
   }
    
    func showAnimation(_ label: UILabel, _ constraint: NSLayoutConstraint, _ valid: Bool) {
        if label.alpha == 1 && valid {
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveLinear, animations: { [weak self] in
                label.alpha = 0
                constraint.constant -= 15
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
        if label.alpha == 0 && !valid {
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveLinear, animations: { [weak self] in
                label.alpha = 1
                constraint.constant += 15
                self?.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func roundView(_ views:UIView...) {
        views.forEach { $0.layer.cornerRadius = $0.frame.size.height / 2.0}
    }
    
    func roundButton(_ buttons: UIButton...) {
        buttons.forEach { $0.layer.cornerRadius = $0.frame.size.height / 2.0}
    }
    
    func addViewBorder(_ views:UIView...) {
        views.forEach {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func showAlert(_ title: String, _ text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let attributedText = NSAttributedString(string: text, attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor : UIColor.white ])
        let attributedTitle = NSAttributedString(string: title, attributes: [ NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor : UIColor.white] )
        alert.setValue(attributedText, forKey: "attributedMessage")
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.view.subviews[0].subviews[0].subviews[0].backgroundColor = .init(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.90)
        let okAction = UIAlertAction(title: "OK", style: .default) {_ in}
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let result = formatter.string(from: date)
        return result
    }
    
}
