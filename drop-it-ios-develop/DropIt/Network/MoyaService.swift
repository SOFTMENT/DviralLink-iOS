//
//  MoyaService.swift
//  DropIt
//
//

import Moya
import UIKit

enum MoyaService {
    case postSignUp(email: String, password: String, confirmPassword: String)
    case postSignIn(email: String, password: String)
    case getResetPassword(email: String)
    case patchSetPassword(email: String, password: String, confirmPassword: String)
    case getUser(id: Int)
    case putUpdateUser(id: Int, name: String, aboutUser: String, instagramAccount: String, twitterAccount: String)
    case postCreatePost(id: Int, link: String)
    case deletePost(id: Int)
    case postSocialSignIn(token: String, provider: String)
    case getPosts
    case getPost(id: Int)
    case getComments(id: Int)
    case deleteComments(id: Int)
    case postCreateComment(id: Int, idAuthor: Int, text: String)
    case patchUserViews
    case getUserViews(id: Int)
    case postNotifications(deviceId: String)
}

// MARK: - Extentions
// MARK: - TargetType
extension MoyaService: TargetType {
    
    var baseURL: URL {
        return URL(string: ApiConstants.urlBase)!
    }
    
    var path: String {
        switch self {
        case .postSignUp:
            return "/sign-up"
        case .postSignIn:
            return "/sign-in"
        case .getResetPassword:
            return "/reset-password"
        case .patchSetPassword:
            return "/set-password"
        case .getUser(let id):
            return "/users/\(id)"
        case .putUpdateUser(let id, _, _, _, _):
            return "/users/\(id)"
        case .postCreatePost:
            return "/posts"
        case .deletePost(let id):
            return "/posts/\(id)"
        case .postSocialSignIn:
            return "/social-login"
        case .getPosts:
            return "/posts"
        case .getComments(let id):
            return "/posts/\(id)/comments"
        case .deleteComments(let id):
            return "/comments/\(id)"
        case .getPost(let id):
            return "/posts/\(id)"
        case .postCreateComment(let id, _, _):
            return "/posts/\(id)/comments"
        case .patchUserViews:
            return "/users/views"
        case .getUserViews(let id):
            return "/users/\(id)/views"
        case .postNotifications:
            return "/users/notifications"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postSignUp:
            return .post
        case .postSignIn:
            return .post
        case .getResetPassword:
            return .get
        case .patchSetPassword:
            return .patch
        case .getUser:
            return .get
        case .putUpdateUser:
            return .put
        case .postCreatePost:
            return .post
        case .deletePost:
            return .delete
        case .postSocialSignIn:
            return .post
        case .getPosts:
            return .get
        case .getComments:
            return .get
        case .deleteComments:
            return .delete
        case .getPost:
            return .get
        case .postCreateComment:
            return .post
        case .patchUserViews:
            return .patch
        case .getUserViews:
            return .get
        case .postNotifications:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .postSignIn(let email, let password):
            return "{\"email\": \(email), \"password\": \"\(password)\"}".utf8Encoded
        case .postSignUp:
            return Data()
        case .getResetPassword:
            return Data()
        case .patchSetPassword:
            return Data()
        case .getUser:
            return Data()
        case .putUpdateUser(_, let name, let aboutUser, let instagramAccount, let twitterAccount):
            return "{\"name\": \(name), \"aboutUser\": \"\(aboutUser)\", \"instagramAccount\": \"\(instagramAccount)\", \"twitterAccount\": \"\(twitterAccount)\"}".utf8Encoded
        case .postCreatePost:
            return Data()
        case .deletePost:
            return Data()
        case .postSocialSignIn(let token, let provider):
            return "{\"token\": \(token), \"authenticationProvider\": \"\(provider)\"}".utf8Encoded
        case .getPosts:
            return Data()
        case .getComments:
            return Data()
        case .deleteComments:
            return Data()
        case .getPost:
            return Data()
        case .postCreateComment(_, idAuthor: let idAuthor, text: let text):
            return "{\"text\": \(text), \"authorId\": \"\(idAuthor)\"}".utf8Encoded
        case .patchUserViews:
            return Data()
        case .getUserViews:
            return Data()
        case .postNotifications(let deviceId):
            return "{\"token\": \(deviceId)}".utf8Encoded
        }
    }
    
    var task: Task {
        switch self {
        case .postSignUp(let email, let password, let confirmPassword):
            return .requestParameters(parameters: ["email" : email, "password" : password, "confirmPassword" : confirmPassword], encoding: JSONEncoding.default)
        case .postSignIn(let email, let password):
            return .requestParameters(parameters: ["email" : email, "password" : password], encoding: JSONEncoding.default)
        case .getResetPassword(let email):
            return .requestParameters(parameters: ["email" : email], encoding: URLEncoding.default)
        case .patchSetPassword(let email, let password, let confirmPassword):
            return .requestParameters(parameters: ["email" : email, "password" : password, "confirmPassword" : confirmPassword], encoding: JSONEncoding.default)
        case .getUser:
            return .requestPlain
        case .putUpdateUser(_, let name, let aboutUser, let instagramAccount, let twitterAccount):
            return .requestParameters(parameters: ["name" : name, "aboutUser" : aboutUser, "instagramAccount" : instagramAccount, "twitterAccount" : twitterAccount], encoding: JSONEncoding.default)
        case .postCreatePost(let id, let link):
            return .requestParameters(parameters: ["authorId" : id, "link" : link], encoding: JSONEncoding.default)
        case .deletePost:
            return .requestPlain
        case .postSocialSignIn(let token, let provider):
            return .requestParameters(parameters: ["token" : token, "authenticationProvider" : provider], encoding: JSONEncoding.default)
        case .getPosts:
            return .requestPlain
        case .getComments:
            return .requestPlain
        case .deleteComments:
            return .requestPlain
        case .getPost:
            return .requestPlain
        case .postCreateComment(_, let idAuthor, let text):
            return .requestParameters(parameters: ["text" : text, "authorId" : idAuthor], encoding: JSONEncoding.default)
        case .patchUserViews:
            return .requestPlain
        case .getUserViews:
            return .requestPlain
        case .postNotifications(let deviceId):
            return .requestParameters(parameters: ["token" : deviceId], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type" : "application/json", "Authorization" : "Bearer \(Sessions.token)"]
        
    }
}

// MARK: - AccessTokenAuthorizable
extension MoyaService: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        switch self {
        case .postSignUp:
            return .none
        case .postSignIn:
            return .none
        case .getResetPassword:
            return .none
        case .patchSetPassword:
            return .none
        case .getUser:
            return .bearer
        case .putUpdateUser:
            return .bearer
        case .postCreatePost:
            return .bearer
        case .deletePost:
            return .bearer
        case .postSocialSignIn:
            return .none
        case .getPosts:
            return .bearer
        case .getComments:
            return .bearer
        case .deleteComments:
            return .bearer
        case .getPost:
            return .bearer
        case .postCreateComment:
            return .bearer
        case .patchUserViews:
            return .bearer
        case .getUserViews:
            return .bearer
        case .postNotifications:
            return .bearer
        }
    }
}
