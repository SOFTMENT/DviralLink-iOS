//
//  MoyaManager.swift
//  DropIt
//
//

import Moya
import Moya_ObjectMapper

class MoyaManager {
    
    let loggerConfig = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
    var moyaProvider: MoyaProvider<MoyaService>
    
    init() {
        let networkLogger = NetworkLoggerPlugin(configuration: loggerConfig)
        moyaProvider = MoyaProvider<MoyaService>(plugins: [networkLogger])
    }
    
    func requestSignIn (_ email: String, _ password: String, completion: @escaping ((Int, SignInModel) -> Void)) {
       moyaProvider.request(.postSignIn(email: email, password: password)) { result in
            switch result {
            case .success(let response) :
                 let inviteResponse = try? response.mapObject(SignInModel.self)
                completion(response.statusCode, inviteResponse ?? SignInModel())
            case .failure(let error):
                print(error)
            }
        }
    }

    func requestSignUp (_ email: String, _ password: String, _ confirmPassword: String, completion: @escaping ((Int) -> Void)) {
        moyaProvider.request(.postSignUp(email: email, password: password, confirmPassword: confirmPassword)) { result in
            switch result {
            case .success(let response) :
                completion(response.statusCode)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestResetPassword (_ email: String, completion: @escaping ((Int) -> Void)) {
        moyaProvider.request(.getResetPassword(email: email)) { result in
            switch result {
            case .success(let response) :
                completion(response.statusCode)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestSetPassword (_ email: String, _ password: String, _ confirmPassword: String, completion: @escaping ((Int) -> Void)) {
        moyaProvider.request(.patchSetPassword(email: email, password: password, confirmPassword: confirmPassword)) { result in
            switch result {
            case .success(let response) :
                completion(response.statusCode)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestGetUser (_ id: Int, completion: @escaping ((Int, UserModel) -> Void)) {
        moyaProvider.request(.getUser(id: id)) { result in
             switch result {
             case .success(let response) :
                  let inviteResponse = try? response.mapObject(UserModel.self)
                  completion(response.statusCode, inviteResponse ?? UserModel())
             case .failure(let error):
                 print(error)
             }
         }
    }
    
    func requestUpdateUser (_ id: Int, _ name: String, _ aboutUser: String, _ instagramAccount: String, _ twitterAccount: String, completion: @escaping ((Int, UserModel) -> Void)) {
        moyaProvider.request(.putUpdateUser(id: id, name: name, aboutUser: aboutUser, instagramAccount: instagramAccount, twitterAccount: twitterAccount)) { result in
            switch result {
            case .success(let response) :
                 let inviteResponse = try? response.mapObject(UserModel.self)
                completion(response.statusCode, inviteResponse ?? UserModel())
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestCreatePost (_ id: Int, _ link: String, completion: @escaping ((Int, String, PostModel) -> Void)) {
        moyaProvider.request(.postCreatePost(id: id, link: link)) { result in
            switch result {
            case .success(let response) :
                 let inviteResponse = try? response.mapObject(PostModel.self)
                let messageResponse = String(data: response.data, encoding: String.Encoding.utf8)
                completion(response.statusCode, messageResponse ?? "", inviteResponse ?? PostModel())
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestDeletePost(_ id: Int, completion: @escaping ((Int) -> Void)) {
        moyaProvider.request(.deletePost(id: id)) { result in
            switch result {
            case .success(let response) :
                completion(response.statusCode)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestSocialSignIn (_ token: String, _ provider: String, completion: @escaping ((Int, SignInModel) -> Void)) {
        moyaProvider.request(.postSocialSignIn(token: token, provider: provider)) { result in
            switch result {
            case .success(let response) :
                 let inviteResponse = try? response.mapObject(SignInModel.self)
                completion(response.statusCode, inviteResponse ?? SignInModel())
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestPosts (completion: @escaping ((Int, [PostsModel]) -> Void)) {
        moyaProvider.request(.getPosts) { result in
            switch result {
            case .success(let response) :
                let inviteResponse = try? response.mapArray(PostsModel.self)
                completion(response.statusCode, inviteResponse ?? [PostsModel()])
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestGetPost (_ id: Int, completion: @escaping ((Int, PostModel) -> Void)) {
        moyaProvider.request(.getPost(id: id)) { result in
             switch result {
             case .success(let response) :
                  let inviteResponse = try? response.mapObject(PostModel.self)
                  completion(response.statusCode, inviteResponse ?? PostModel())
             case .failure(let error):
                 print(error)
             }
         }
    }
    
    func requestDeleteComment(_ id: Int, completion: @escaping ((Int) -> Void)) {
        moyaProvider.request(.deleteComments(id: id)) { result in
            switch result {
            case .success(let response) :
                completion(response.statusCode)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestGetComments (_ id: Int, completion: @escaping ((Int, [CommentModel]) -> Void)) {
        moyaProvider.request(.getComments(id: id)) { result in
            switch result {
            case .success(let response) :
                let inviteResponse = try? response.mapArray(CommentModel.self)
                completion(response.statusCode, inviteResponse ?? [CommentModel()])
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestCreateComments (_ idPost: Int, _ idAuthor: Int, _ text: String, completion: @escaping ((Int, CommentModel) -> Void)) {
        moyaProvider.request(.postCreateComment(id: idPost, idAuthor: idAuthor, text: text) ) { result in
            switch result {
            case .success(let response) :
                let inviteResponse = try? response.mapObject(CommentModel.self)
                completion(response.statusCode, inviteResponse ?? CommentModel())
            case .failure(let error):
                print(error)
            }
        }
    }
        
    func requestUsersView (completion: @escaping ((Int) -> Void)) {
        moyaProvider.request(.patchUserViews) { result in
             switch result {
             case .success(let response) :
                  completion(response.statusCode)
             case .failure(let error):
                 print(error)
             }
         }
    }
    
    func requestGetViews (_ id: Int, completion: @escaping ((Int, String) -> Void)) {
        moyaProvider.request(.getUserViews(id: id)) { result in
            switch result {
            case .success(let response) :
                let messageResponse = String(data: response.data, encoding: String.Encoding.utf8)
                completion(response.statusCode, messageResponse ?? "")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestNotifications (_ deviceId: String, completion: @escaping ((Int) -> Void)) {
        moyaProvider.request(.postNotifications(deviceId: deviceId)) { result in
            switch result {
            case .success(let response):
                completion(response.statusCode)
            case .failure(let error):
                print(error)
            }
        }
    }
}
