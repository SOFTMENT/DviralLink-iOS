//
//  UserModel.swift
//  DropIt
//
//

import ObjectMapper

struct UserModel {
    var id: Int = 0
    var email: String = ""
    var name: String = ""
    var aboutUser: String = ""
    var instagramAccount: String = ""
    var twitterAccount: String = ""
    var admin: Bool = false
}

extension UserModel: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        name <- map["name"]
        aboutUser <- map["aboutUser"]
        instagramAccount <- map["instagramAccount"]
        twitterAccount <- map["twitterAccount"]
        admin <- map["admin"]
    }
}
