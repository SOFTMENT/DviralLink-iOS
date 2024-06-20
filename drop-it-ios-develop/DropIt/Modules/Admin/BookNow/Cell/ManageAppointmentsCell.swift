//
//  ManageAppointmentsCell.swift
//  DropIt
//
//  Created by Vijay Rathore on 01/11/22.
//

import UIKit

class ManageAppointmentsCell : UITableViewCell {
    
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var approveAndCancelView: UIStackView!
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var totalDuration: UILabel!
    
    @IBOutlet weak var dateAndTime: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var mailAddress: UILabel!
    
    @IBOutlet weak var status: UILabel!
    
    @IBOutlet weak var approveBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    override class func awakeFromNib() {
        
        
        
    }
}
