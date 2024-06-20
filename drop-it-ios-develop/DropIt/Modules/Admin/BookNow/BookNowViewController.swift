//
//  BookNowViewController.swift
//  DropIt
//
//  Created by Vijay Rathore on 16/10/22.
//

import UIKit
import SDWebImage
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

class BookNowViewConroller : UIViewController {
    
    @IBOutlet weak var backBtn: UIView!
    
    @IBOutlet weak var no_studios_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsBtn: UIButton!
    
    var studios = Array<StudioModel>()
    
    override func viewDidLoad() {
        
        settingsBtn.layer.cornerRadius = 8
        settingsBtn.dropShadow()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backBtn.layer.cornerRadius = 8
        backBtn.dropShadow()
        
        //GETALLSTUDIO
        getAllStudio()
    }
    
    
    @objc func studioCellClicked(value : MyGest) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit Studio", style: .default, handler: { action in
            self.performSegue(withIdentifier: "editStudiSeg", sender: self.studios[value.position])
        }))
        alert.addAction(UIAlertAction(title: "Manage Appointments", style: .default, handler: { action in
            self.performSegue(withIdentifier: "manageAppointmentSeg", sender:self.studios[value.position].id ?? "123")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editStudiSeg" {
            if let vc = segue.destination as? EditStudioViewController {
                if let studio = sender as? StudioModel {
                    vc.studio = studio
                }
            }
        }
        else if segue.identifier == "manageAppointmentSeg" {
            if let vc = segue.destination as? ManageAppointments {
                if let studioId = sender as? String {
                    vc.studioID = studioId
                }
            }
        }
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
    
    @IBAction func settingsBtnClicked(_ sender: Any) {
        let alert  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Add Studio", style: .default,  handler: { action in
            
            self.performSegue(withIdentifier: "addStudioSeg", sender: nil)
        }))
  
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
        
}

extension BookNowViewConroller : UITableViewDelegate, UITableViewDataSource {
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "booknowcell", for: indexPath) as? BookNowTableViewCell {
            
            cell.mView.layer.cornerRadius = 8
            cell.mImage.layer.cornerRadius = 6
            cell.mView.dropShadow()
            
            let studio = self.studios[indexPath.row]
            
            if let imagePath = studio.image, !imagePath.isEmpty {
                cell.mImage.sd_setImage(with: URL(string: imagePath), placeholderImage: UIImage(named: "placeholder"))
            }
            
            cell.mTitle.text = studio.name ?? "Title"
            cell.mAddress.text = studio.address ?? "Address"
            cell.mPrice.text = "\(studio.price ?? 0)$ / hour"
            
            
            cell.mView.isUserInteractionEnabled = true
            let myGest = MyGest(target: self, action: #selector(studioCellClicked(value: )))
            myGest.position = indexPath.row
            cell.mView.addGestureRecognizer(myGest)
            
            return cell
        }
        return BookNowTableViewCell()
    }
    
}


class MyGest : UITapGestureRecognizer {
    var id : String = "123"
    var position : Int = 0
}
