//
//  UserBookNowViewController.swift
//  DropIt
//
//  Created by Vijay Rathore on 17/10/22.
//

import UIKit
import FirebaseFirestore
import Firebase

class UserBookNowViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var no_studios_available: UILabel!
    var studios = Array<StudioModel>()
    var totalTime = 1
   
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        
        getAllStudio()
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    func getAllStudio() {
        progressHUDShow(text: "Loading...")
        Firestore.firestore().collection("Studios").order(by: "name").addSnapshotListener { snapshot, error in
            self.progressHUDHide()
            if error == nil {
                self.studios.removeAll()
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let studio = try? qdr.data(as: StudioModel.self) {
                            self.studios.append(studio)
                        }
                     
                    }
                }
                
                self.tableView.reloadData()
            }
            else {
                self.showMyError(error!.localizedDescription)
            }
        }
        
    }
    
    @objc func bookNowBtnClicked(value : UITapGestureRecognizer){
        let alert = UIAlertController(title: "Select Duration", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "1 Hour", style: .default,handler: { action in
            self.totalTime = 1
            let position = value.view!.tag
            self.showStudio(position: position)
        }))
        
        alert.addAction(UIAlertAction(title: "2 Hours", style: .default,handler: { action in
            self.totalTime = 2
            let position = value.view!.tag
            self.showStudio(position: position)
        }))
        
        alert.addAction(UIAlertAction(title: "3 Hours", style: .default,handler: { action in
            self.totalTime = 3
            let position = value.view!.tag
            self.showStudio(position: position)
        }))
        
        alert.addAction(UIAlertAction(title: "4 Hours", style: .default,handler: { action in
            self.totalTime = 4
            let position = value.view!.tag
            self.showStudio(position: position)
        }))
        
        present(alert, animated: true)
        
    }
    
    @objc func showStudio(position : Int){
        self.performSegue(withIdentifier: "showStudioSeg", sender: self.studios[position])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStudioSeg" {
            if let vc = segue.destination as? ShowStudioViewController {
                if let studio = sender as? StudioModel {
                    vc.studio = studio
                    vc.totaltime = self.totalTime
                }
            }
        }
    }
}


extension UserBookNowViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if studios.count > 0 {
            self.no_studios_available.isHidden = true
        }
        else {
            self.no_studios_available.isHidden = false
        }
        
        return studios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userbooknowcell", for: indexPath) as? UserBookNowTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            cell.mImage.layer.cornerRadius = 6
            cell.mView.dropShadow()
            cell.bookNowBtn.layer.cornerRadius = 8
         
            cell.bookNowBtn.tag = indexPath.row
            cell.bookNowBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bookNowBtnClicked(value:))))
            
            let studio = self.studios[indexPath.row]
            
            if let imagePath = studio.image, !imagePath.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage(named: "placeholder"))
            }
            
            cell.mName.text = studio.name ?? "Title"

            cell.mPrice.text = "\(studio.price ?? 0)$ / hour"
            
            return cell
        }
        return UserBookNowTableViewCell()
    }
    
}
