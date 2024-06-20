//
//  BaseViewController.swift
//  DropIt
//
//

import AMPopTip
import MBProgressHUD
import Reachability
import UIKit

class BaseViewController: UIViewController {
    
    private let popTip = PopTip()
    var reachability = try? Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showPasswordInfo(_ button: UIButton, _ number: Int) {
        popTip.bubbleColor = .init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.76)
        var infoString = "Password must be:\n - at least 8 characters and up to 30 characters\n - have at least 1 lowercase character"
        infoString += "\n - contain 1 uppercase letter\n - contain a number\n - contain non-alphanumeric."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        let fontStyle = UIFont.systemFont(ofSize: 14)
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle, .font: fontStyle, .foregroundColor: UIColor.white]
        let attributedString = NSAttributedString(string: infoString , attributes:attributes)
        let oldView = view.subviews[number]
        oldView.frame = CGRect(x: oldView.frame.minX, y: oldView.frame.minY, width: oldView.frame.width - 30, height: oldView.frame.height)
        popTip.show(attributedText: attributedString, direction: .up, maxWidth: 200, in: oldView, from: button.frame)
    }

    func hidePassword(_ field: UITextField, _ button: UIButton) {
        if field.isSecureTextEntry {
            field.isSecureTextEntry = false
            button.setImage(UIImage(named: "icOpenEyePassword.png")!, for: .normal)
        } else {
            field.isSecureTextEntry = true
            button.setImage(UIImage(named: "icCloseEyePassword.png")!, for: .normal)
        }
    }
    
    func showLoading() {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Loading..."
        hud.minShowTime = 1.0
        hud.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.4)
        hud.contentColor = .init(red: 1, green: 1, blue: 1, alpha: 0.8)
        hud.bezelView.color = .init(red: 0, green: 0, blue: 0, alpha: 0.8)
        hud.bezelView.style = .solidColor
        DispatchQueue.main.sync {
            hud.hide(animated: true)
        }
    }
    
    func checkConnection() {
        reachability = try? Reachability()
    }
    
    func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
      }

      func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
          .replacingOccurrences(of: "-", with: "+")
          .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
          let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
          base64 += padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
      }

      func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
          let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }
        return payload
      }
}
