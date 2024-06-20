//
//  CommentModel.swift
//  DropIt
//
//

import ObjectMapper

struct CommentModel {
    var id = 0
    var userId = 0
    var userName = ""
    var text = ""
    var creationTime = ""
}

extension CommentModel: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        userName <- map["userName"]
        text <- map["text"]
        creationTime <- map["creationTime"]
    }
}
