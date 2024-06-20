//
//  PostModel.swift
//  DropIt
//
//

import ObjectMapper

struct PostModel {
    var id: Int = 0
    var link: String = ""
    var creationTime: String = ""
    var picture: String = String()
    var songName: String = ""
    var author: UserModel = UserModel()
    var commentsNumber = 0
}

extension PostModel: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        link <- map["link"]
        creationTime <- map["creationTime"]
        var image: String = "" 
        image <- map["picture"]
        picture = image
        songName <- map["songName"]
        author <- map["author"]
        commentsNumber <- map["commentsNumber"]
    }
}
