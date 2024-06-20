//
//  File.swift
//  DropIt
//
//

import CoreData
import UIKit

class CoreDataManager {
    let context: NSManagedObjectContext = ((UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext)!
    
    func addUser(_ id: Int, _ token: String, _ email: String) {
        let userRequest = User.fetchRequest() as NSFetchRequest<User>
        do {
            let items = try context.fetch(userRequest)
            if items.isEmpty {
                let user = User(context: context)
                user.id = Int64(id)
                user.token = token
                user.email = email
                do {
                    context.insert(user)
                    try context.save()
                } catch {
                    print("addUser: error in create user")
                }
            }
        } catch {
            print("addUser: error in create user")
        }
    }
    
    func addRole(_ id: Int, _ role: String) {
        let admin = role == "ADMIN" ? true : false
        let userRequest = User.fetchRequest() as NSFetchRequest<User>
        userRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
        do {
            let items = try context.fetch(userRequest)
            for item in 0..<items.count {
                items[item].admin = admin
            }
            try context.save()
            print(items[0])
        } catch {
            print("Error in update User")
        }
    }
    
    func removeUser() {
        let request = User.fetchRequest() as NSFetchRequest<User>
        do {
            let items = try context.fetch(request)
            if items.isEmpty {
                print("removeUser: nobody deleted")
                return
            }
            for item in 0..<items.count {
                context.delete(items[item])
                try context.save()
            }
            print("removeUser: deleted")
        } catch {
            print("removeUser: Error in deleting")
        }
    }
    
    func printUser() {
        let request = User.fetchRequest() as NSFetchRequest<User>
        do {
            let items = try context.fetch(request)
            for item in 0..<items.count {
                print(items[item].id)
                print(items[item].email ?? "Nothing")
                print(items[item].name ?? "Nothing")
                print(items[item].aboutUser ?? "Nothing")
                print(items[item].token ?? "Nothing")
                print(items[item].twitterAccount ?? "Nothing")
                print(items[item].instagramAccount ?? "Nothing")
                print(items[item].admin)
            }
        } catch { print("printUser: error in print users") }
    }
    
    func updateUser(_ id: Int, _ name: String, _ aboutUser: String, _ twitter: String, _ instagram: String) {
        let userRequest = User.fetchRequest() as NSFetchRequest<User>
        userRequest.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
        do {
            let items = try context.fetch(userRequest)
            for item in 0..<items.count {
                items[item].name = name
                items[item].aboutUser = aboutUser
                items[item].twitterAccount = twitter
                items[item].instagramAccount = instagram
            }
            try context.save()
            print(items[0])
        } catch {
            print("Error in update User")
        }
    }
    
    func getUser() -> User {
        var user = User()
        let request = User.fetchRequest() as NSFetchRequest<User>
        do {
            let userData = try context.fetch(request)
            user = userData[0]
        } catch { print("getUser: error in get user") }
        return user
    }
    
    func checkUser() -> Bool {
        let request = User.fetchRequest() as NSFetchRequest<User>
        do {
            let user = try context.fetch(request)
            if user.isEmpty {
                return false
            }
        } catch { print("checkUser: error in check user") }
        return true
    }
    
    func printViews() {
        let request = UserView.fetchRequest() as NSFetchRequest<UserView>
        do {
            let items = try context.fetch(request)
            for item in 0..<items.count {
                print(items[item].idPost)
                print(items[item].idUser)
                print(items[item].time ?? "")
            }
        } catch { print("printViews: error in print views") }
    }
    
    func addView(_ id: Int, _ idPost: Int, _ time: String) {
        do {
            let view = UserView(context: context)
            view.idUser = Int64(id)
            view.idPost = Int64(idPost)
            view.time = time
            do {
                context.insert(view)
                try context.save()
            } catch {
                print("addView: error in create view")
            }
        } 
    }
    
    func checkView(_ userId: Int, _ postId: Int) -> Bool {
        let viewRequest = UserView.fetchRequest() as NSFetchRequest<UserView>
        viewRequest.predicate = NSPredicate(format: "idPost == %@", NSNumber(value: postId))
        do {
            let items = try context.fetch(viewRequest)
            for item in 0..<items.count where items[item].idUser == userId {
                    return true
            }
        } catch {
            print("Error in get Views")
        }
        return false
    }
    
    func removeView() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let weeksAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: date)!
        let timeDelete = formatter.string(from: weeksAgoDate)
        let request = UserView.fetchRequest() as NSFetchRequest<UserView>
        do {
            let items = try context.fetch(request)
            for item in 0..<items.count where items[item].time == timeDelete {
                context.delete(items[item])
                try context.save()
            }
        } catch { print("removeViews: error in delete view") }
    }
    
    func addPost(_ id: Int, _ author: String, _ link: String, _ songName: String, _ creationTime: String, _ picture: String, _ commentsNumber: Int) {
        let postRequest = Post.fetchRequest() as NSFetchRequest<Post>
        do {
            let items = try context.fetch(postRequest)
            if items.isEmpty {
                let post = Post(context: context)
                post.id = Int64(id)
                post.link = link
                post.creaationTime = creationTime
                post.picture = picture
                post.songName = songName
                post.author = author
                post.commentsNumber = Int64(commentsNumber)
                do {
                    context.insert(post)
                    try context.save()
                } catch {
                    print("addPost: error in create post")
                }
            }
        } catch {
            print("addPost: error in create post")
        }
    }
    
    func removePost() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let weeksAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: date)!
        let timeDelete = formatter.string(from: weeksAgoDate)
        let request = Post.fetchRequest() as NSFetchRequest<Post>
        do {
            let items = try context.fetch(request)
            for item in 0..<items.count where items[item].creaationTime == timeDelete {
                context.delete(items[item])
                try context.save()
            }
        } catch { print("removePost: error in delete post") }
    }
    
    func printPosts() {
        let request = Post.fetchRequest() as NSFetchRequest<Post>
        do {
            let items = try context.fetch(request)
            for item in 0..<items.count {
                print(items[item].id)
                print(items[item].author ?? "")
                print(items[item].link ?? "")
                print(items[item].picture ?? "")
                print(items[item].songName ?? 0)
                print(items[item].commentsNumber)
                print(items[item].creaationTime ?? "")
            }
        } catch { print("printPosts: error in print posts") }
    }
    
    func updateView(_ comments: Int, _ idPost: Int) {
        let request = Post.fetchRequest() as NSFetchRequest<Post>
        request.predicate = NSPredicate(format: "id == %@", NSNumber(value: idPost))
        do {
            let items = try context.fetch(request)
            for item in 0..<items.count {
                items[item].commentsNumber = Int64(comments)
            }
            try context.save()
            print(items[0])
        } catch {
            print("Error in update User")
        }
    }
}
