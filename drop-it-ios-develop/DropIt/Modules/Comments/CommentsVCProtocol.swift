//
//  CommentsVCProtocol.swift
//  DropIt
//
//

import UIKit

protocol CommentsVCProtocol: class {
    func moveToUserProfile(button: UIButton, id: Int)
    func moveToPlayer(button: UIButton)
    func deleteComment(button: UIButton, id: Int)
}
