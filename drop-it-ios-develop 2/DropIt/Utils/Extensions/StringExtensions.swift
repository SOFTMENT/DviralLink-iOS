//
//  StringExtensions.swift
//  DropIt
//
//

import UIKit

extension String {
    func isPasswordValidate() -> Bool {
        let passwordPattern = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()\\-_=+{}|?>.<,:;~`’])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,30}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordPattern).evaluate(with: self)
    }
    
    func isEmailValidate() -> Bool {
        let pattern = "[A-Z0-9a-z._]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
    
    func isLinkValidate() -> Bool {
       guard let url = URL(string: self), UIApplication.shared.canOpenURL(url) else { return false }
        let regEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%:]*)?$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: self)
    }
    
    func isInstagramValidate() -> Bool {
        let regEx = "[0-9a-zA-Z_.]{2,100}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        print(predicate.evaluate(with: self))
        return predicate.evaluate(with: self)
    }
    
    func isTwitterValidate() -> Bool {
        let regEx = "[0-9a-zA-Z_]{2,100}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        print(predicate.evaluate(with: self))
        return predicate.evaluate(with: self)
    }
    
    func setupDate() -> String {
        let month = self[self.index(self.startIndex, offsetBy: 3)..<self.index(self.endIndex, offsetBy: -5)]
        let day = self.prefix(2)
        var dateOfPost = ""
        switch month {
        case "01":
            dateOfPost = day + " January"
        case "02":
            dateOfPost = day + " February"
        case "03":
            dateOfPost = day + " March"
        case "04":
            dateOfPost = day + " April"
        case "05":
            dateOfPost = day + " May"
        case "06":
            dateOfPost = day + " June"
        case "07":
            dateOfPost = day + " July"
        case "08":
            dateOfPost = day + " August"
        case "09":
            dateOfPost = day + " September"
        case "10":
            dateOfPost = day + " October"
        case "11":
            dateOfPost = day + " November"
        case "12":
            dateOfPost = day + " December"
        default: break
        }
        return dateOfPost
    }

}
