//
//  UserView+CoreDataProperties.swift
//  
//
//
//

import CoreData

extension UserView {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserView> {
        return NSFetchRequest<UserView>(entityName: "UserView")
    }

    @NSManaged public var idPost: Int64
    @NSManaged public var idUser: Int64
    @NSManaged public var time: String?
}
