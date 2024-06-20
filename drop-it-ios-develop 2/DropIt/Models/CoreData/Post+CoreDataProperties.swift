//
//  Post+CoreDataProperties.swift
//  
//
//  Created by user on 7/6/21.
//
//

import Foundation
import CoreData

extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var author: String?
    @NSManaged public var commentsNumber: Int64
    @NSManaged public var creaationTime: String?
    @NSManaged public var id: Int64
    @NSManaged public var image: Data?
    @NSManaged public var link: String?
    @NSManaged public var picture: String?
    @NSManaged public var songName: String?

}
