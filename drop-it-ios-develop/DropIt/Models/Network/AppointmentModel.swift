//
//  AppointmentModel.swift
//  DropIt
//
//  Created by Vijay Rathore on 18/10/22.
//

import UIKit

class AppointmentModel : NSObject, Codable {
    var id : String?
    var appointmentDate : Date?
    var appointmentStarTime : String?
    var appointmentHour : Int?
    var totalPrice : Int?
    var userEmail : String?
    var studioName : String?
    var studioId : String?
    var orderID : String?
    var orderTime : Date?
    var appointmentDateString : String?
    var selectedHours : [Int]?
    var userName : String?
    var status : String?
    var phoneNumber : String?
}
