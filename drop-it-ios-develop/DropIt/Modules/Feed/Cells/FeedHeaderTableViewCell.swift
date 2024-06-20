//
//  FeedHeaderTableViewCell.swift
//  DropIt
//
//

import UIKit

class FeedHeaderTableViewCell: UITableViewHeaderFooterView {
    
    @IBOutlet weak private var dataLabel: UILabel!
    
    public func configure(_ data: String) {
        dataLabel.text = data
    }
    
}
