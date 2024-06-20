//
//  FeedTableViewCell.swift
//  DropIt
//
//

import UIKit
import Kingfisher

class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var songLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var linkButton: UIButton!
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var authorButton: UIButton!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var commentsLabel: UILabel!
    @IBOutlet private weak var cellView: UIView!
    @IBOutlet private weak var coverView: UIView!
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var darkView: UIView!
    
    weak var delegate: FeedVCProtocol?
    private var id = 0
    private var date = ""
    private var idAuthor = 0
    private var nameOfAuthor = ""
    private let coredataManager = CoreDataManager()
    private var imageCell = UIImage()
    
    // MARK: - Setup
    static func nib() -> UINib {
        return UINib(nibName: "FeedTableViewCell", bundle: nil)
    }
    
    public func configure(_ song: String, _ isDelete: Bool, _ link: String, _ image: String, _ author: String, _ time: String, _ comments: Int, _ id: Int, _ date: String, _ idAuthor: Int, _ isDark: Bool, _ name: String) {
        self.songLabel.text = song
        self.deleteButton.isHidden = isDelete ? false : true
        self.coverImageView.kf.setImage(with: URL(string: image), placeholder: UIImage(named: "imCover"))
      //  self.coverImageView.image = (UIImage(contentsOfFile: image) ?? UIImage(named: "imCover"))!
        self.authorButton.setTitle(" \(author)", for: .normal)
        self.timeLabel.text = time
        self.linkButton.setTitle(link, for: .normal)
        self.commentsLabel.attributedText = setupCommentsLabel(comments)
        if comments == 0 {
            commentsButton.setTitle("Leave a comment >", for: .normal)
        } else {
            commentsButton.setTitle("View all >", for: .normal)
        }
        self.cellView.layer.cornerRadius = 10
        self.id = id
        self.date = date
        self.idAuthor = idAuthor
        self.coverView.layer.cornerRadius = 7
        if coredataManager.getUser().admin {
            self.darkView.isHidden = true
        } else {
            self.darkView.isHidden = isDark
        }
        self.nameOfAuthor = name
        self.imageCell = (UIImage(contentsOfFile: image) ?? UIImage(named: "imCover"))!
    }
    
    private func setupCommentsLabel(_ comments: Int) -> NSMutableAttributedString {
        let fullString = NSMutableAttributedString(string: "Comments ")
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: "icComments")
        imageAttachment.bounds = CGRect(x: 0, y: -2.5, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        let imageString = NSAttributedString(attachment: imageAttachment)
        fullString.append(imageString)
        fullString.append(NSAttributedString(string: " \(comments)"))
        return fullString
    }
    
    // MARK: - Actions
    @IBAction private func tappedDelete(_ sender: UIButton) {
        delegate?.deletePosts(button: sender, id: id)
    }
    
    @IBAction private func tappedLink(_ sender: UIButton) {
        delegate?.moveToPlayer(button: sender, id: id, image: imageCell)
    }
    
    @IBAction private func tappedComments(_ sender: UIButton) {
        delegate?.moveToComments(button: sender, id: id, date: date, name: nameOfAuthor)
    }
    
    @IBAction private func tappedAuthor(_ sender: UIButton) {
        delegate?.moveToUserProfile(button: sender, id: idAuthor)
    }
}
