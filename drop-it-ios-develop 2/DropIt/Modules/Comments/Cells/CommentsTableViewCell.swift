//
//  CommentsTableViewCell.swift
//  DropIt
//
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak private var deleteButton: UIButton!
    @IBOutlet private weak var authorButton: UIButton!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var commentLabel: UILabel!
    @IBOutlet private weak var ownerLabel: UILabel!
    
    weak var delegate: CommentsVCProtocol?
    private var id = 0
    private var idAuthor = 0
    
    // MARK: - Setup
    static func nib() -> UINib {
        return UINib(nibName: "CommentsTableViewCell", bundle: nil)
    }
    
    public func configure(id: Int, comment: String, delete: Bool, author: String, time: String, idAuthor: Int, owner: Bool) {
        commentLabel.text = comment
        deleteButton.isHidden = !delete
        if id == 0 {
            authorButton.isEnabled = false
            authorButton.setImage(UIImage(), for: .normal)
            authorButton.setTitle("Please leave your comment below", for: .normal)
        } else {
            authorButton.isEnabled = true
            authorButton.setTitle(" \(author)", for: .normal)
            authorButton.setImage(UIImage(named: "icUser"), for: .normal)
        }
        timeLabel.text = time
        self.id = id
        self.idAuthor = idAuthor
//        self.ownerLabel.isHidden = !owner
    }
    
    // MARK: - Actions
    @IBAction private func tappedAuthor(_ sender: UIButton) {
        delegate?.moveToUserProfile(button: sender, id: idAuthor)
    }
    
    @IBAction private func tappedDelete(_ sender: UIButton) {
        delegate?.deleteComment(button: sender, id: id)
    }
}
