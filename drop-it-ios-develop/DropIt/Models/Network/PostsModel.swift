//
//  PageModel.swift
//  DropIt
//
//

import ObjectMapper

struct PostsModel {
    var date = ""
    var posts = [PostModel()]
}

extension PostsModel: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        date <- map["date"]
        posts <- map["posts"]
    }
}
