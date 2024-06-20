//
//  CommentsHeaderTableViewCell.swift
//  DropIt
//
//

import UIKit

class CommentsHeaderTableViewCell: UITableViewHeaderFooterView {

    @IBOutlet weak private var commentsLabel: UILabel!
    
    public func configure(_ commentsCount: Int) {
        commentsLabel.text = "Comments \(commentsCount)"
    }
}
