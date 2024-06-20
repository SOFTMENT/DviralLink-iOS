//
//  User+CoreDataProperties.swift
//  
//
//
//

import CoreData

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var aboutUser: String?
    @NSManaged public var admin: Bool
    @NSManaged public var email: String?
    @NSManaged public var id: Int64
    @NSManaged public var instagramAccount: String?
    @NSManaged public var name: String?
    @NSManaged public var token: String?
    @NSManaged public var twitterAccount: String?
}
