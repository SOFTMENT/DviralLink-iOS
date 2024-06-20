//
//  UIImageExtensions.swift
//  DropIt
//
//

import UIKit

extension UIImage {
  convenience init?(url: URL?) {
    guard let url = url else { return nil }
            
    do {
      self.init(data: try Data(contentsOf: url))
    } catch {
      print("Can not load image from url: \(url) with error: \(error)")
      return nil
    }
  }
}
