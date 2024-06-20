//
//  MainCommentsTableViewCell.swift
//  DropIt
//
//

import UIKit

class MainCommentsTableViewCell: UITableViewCell {
   
    @IBOutlet weak private var songLabel: UILabel!
    @IBOutlet weak private var deleteButton: UIButton!
    @IBOutlet weak private var linkButton: UIButton!
    @IBOutlet weak private var postImageView: UIImageView!
    @IBOutlet weak private var authorButton: UIButton!
    @IBOutlet private weak var postView: UIView!
    @IBOutlet weak private var timeLabel: UILabel!
    
    weak var delegate: CommentsVCProtocol?
    private var idAuthor = 0
    private var section = 0
    
    // MARK: - Setup
    static func nib() -> UINib {
        return UINib(nibName: "MainCommentsTableViewCell", bundle: nil)
    }
    
    public func configure(song: String, link: String, image: UIImage, author: String, time: String, idUser: Int) {
        songLabel.text = song
        linkButton.setTitle(link, for: .normal)
        postImageView.image = image
        authorButton.setTitle(" \(author)", for: .normal)
        timeLabel.text = time
        idAuthor = idUser
        postView.layer.cornerRadius = 7
    }
    
    // MARK: - Actions
    @IBAction private func tappedLinkButton(_ sender: UIButton) {
        delegate?.moveToPlayer(button: sender)
    }
    
    @IBAction private func tappedAuthorButton(_ sender: UIButton) {
        delegate?.moveToUserProfile(button: sender, id: idAuthor)
    }
}
