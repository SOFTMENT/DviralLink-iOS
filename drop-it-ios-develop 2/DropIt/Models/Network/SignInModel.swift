//
//  SignInModel.swift
//  DropIt
//
//

import ObjectMapper

struct SignInModel {
    var token: String = ""
}

extension SignInModel: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        token <- map["token"]
    }
}

class UserToken: Codable {
    @objc dynamic var id = 0
    @objc dynamic var email = ""
    @objc dynamic var role = ""

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case role
    }
    
    required convenience init(data: [String:Any]) {
        self.init()
        id = data[CodingKeys.id.rawValue] as? Int ?? 0
        email = data[CodingKeys.email.rawValue] as? String ?? ""
        role = data[CodingKeys.role.rawValue] as? String ?? ""
    }
}
