//
//  ManageAppointments.swift
//  DropIt
//
//  Created by Vijay Rathore on 01/11/22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ManageAppointments : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var no_appointments_available: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var manageAppointments = Array<AppointmentModel>()
    var studioID : String?
    override func viewDidLoad() {
        
        if studioID == nil {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        backView.layer.cornerRadius = 8
        backView.dropShadow()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        
        getAppointments()
    }
    
    @objc func getAppointments(){
        progressHUDShow(text: "")
        Firestore.firestore().collection("Appointments").whereField("studioId", isEqualTo: studioID!).order(by: "orderTime",descending: true).addSnapshotListener { snapshot, error in
            self.progressHUDHide()
            if let error = error {
                self.showMyError(error.localizedDescription)
            }
            else {
                self.manageAppointments.removeAll()
                if let snapshot = snapshot , !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let appointment = try? qdr.data(as: AppointmentModel.self) {
                            self.manageAppointments.append(appointment)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func approveAppointment(value : MyGest){
        let alert = UIAlertController(title: "Approve", message: "Are you sure you want to approve this appointment?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Approve", style: .default,handler: { action in
            self.progressHUDShow(text: "")
            Firestore.firestore().collection("Appointments").document(self.manageAppointments[value.position].id ?? "123").setData(["status" : "Approved"],merge: true) { error in
                self.progressHUDHide()
                if error == nil {
                  
                    let appointmentModel = self.manageAppointments[value.position]
                    self.sendMail(to_name: appointmentModel.userName ?? "Name" , to_email: appointmentModel.userEmail ?? "Email", subject: "Appointment Apporved", body: "We have approved your \(self.convertDateAndTimeFormater(appointmentModel.appointmentDate ?? Date())) appointment. Thank You")
                    
                    self.showMessage(title: "Approved", message: "Appointment has been approved")
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    @objc func cancelAppointment(value : MyGest){
        let alert = UIAlertController(title: "Reject", message: "Are you sure you want to reject this appointment?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reject", style: .destructive,handler: { action in
            self.progressHUDShow(text: "")
            Firestore.firestore().collection("Appointments").document(self.manageAppointments[value.position].id ?? "123").setData(["status" : "Cancelled"],merge: true) { error in
               
                if error == nil {
                    
                    self.createRefundRequest(paymentID: value.id) { refundId, refundStatus, error in
                        DispatchQueue.main.async {
                            self.progressHUDHide()
                            if let error = error {
                            
                                let appointmentModel = self.manageAppointments[value.position]
                                self.sendMail(to_name: appointmentModel.userName ?? "Name" , to_email: appointmentModel.userEmail ?? "Email", subject: "Appointment Cancelled", body: "Sorry! We have cancelled your \(self.convertDateAndTimeFormater(appointmentModel.appointmentDate ?? Date())) appointment and refunded your full amount. Thank You")
                                
                                self.showMessage(title: "Cancelled", message: "Appointment has been cancelled")
                            }
                            else {
                                self.showMyError(error ?? "ERROR")
                            }
                        }
                        
                    }
                    
                }
                else {
                    self.showMyError(error!.localizedDescription)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ManageAppointments :  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if manageAppointments.count > 0 {
            self.no_appointments_available.isHidden = true
        }
        else {
            self.no_appointments_available.isHidden = false
        }
        return manageAppointments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentcell", for: indexPath) as? ManageAppointmentsCell {
            
            let appointment = self.manageAppointments[indexPath.row]
            cell.approveBtn.layer.cornerRadius = 8
            cell.cancelBtn.layer.cornerRadius = 8
            
            cell.approveBtn.isUserInteractionEnabled = true
            let myGest = MyGest(target: self, action: #selector(approveAppointment(value: )))
        
            myGest.position = indexPath.row
            cell.approveBtn.addGestureRecognizer(myGest)
            
            cell.cancelBtn.isUserInteractionEnabled = true
            let myGest1 = MyGest(target: self, action: #selector(cancelAppointment(value: )))
            myGest1.id = appointment.id ?? "123"
            myGest1.position = indexPath.row
            cell.cancelBtn.addGestureRecognizer(myGest1)
            cell.phoneNumber.text = appointment.phoneNumber ?? "123456789"
            
            cell.totalDuration.text = "\(appointment.appointmentHour ?? 1) Hours"
            cell.dateAndTime.text = "\(self.convertDateFormater(appointment.appointmentDate ?? Date())), \(appointment.appointmentStarTime ?? "")"
            cell.name.text = appointment.userName ?? ""
            cell.mailAddress.text = appointment.userEmail ?? ""
            cell.status.text = appointment.status ?? "Pending"
            cell.totalDuration.text = "\(appointment.appointmentHour ?? 1) Hours"
            
            if appointment.status! != "Pending" {
                cell.approveAndCancelView.isHidden  = true
            }
            else {
                cell.approveAndCancelView.isHidden  = false
            }
            
            return cell
        }
        
        return ManageAppointmentsCell()
    }
    
    
    
    
}
