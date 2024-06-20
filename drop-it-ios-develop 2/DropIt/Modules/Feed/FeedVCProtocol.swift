//
//  FeedVCProtocol.swift
//  DropIt
//
//

import UIKit

protocol FeedVCProtocol: class {
    func moveToPlayer(button: UIButton, id: Int, image: UIImage)
    func moveToComments(button: UIButton, id: Int, date: String, name: String)
    func deletePosts(button: UIButton, id: Int)
    func moveToUserProfile(button: UIButton, id: Int)
}
