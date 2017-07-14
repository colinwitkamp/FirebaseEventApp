//
//  Event.swift
//  FirebaseAssessment
//
//  Created by Dev on 7/13/17.
//  Copyright © 2017 Colin. All rights reserved.
//

import Foundation
import Firebase

class Event {
    var ID: String = ""
    var Name: String = ""
    var Date: TimeInterval
    var Price: Int = 0
    var Address:String = ""
    var Created: TimeInterval
    var Image: String = ""
    
    
    init() {
        Name = ""
        Date = 0
        Price = 0
        Address = ""
        Created = 0 // timestamp
    }
    
    init(name: String, date: TimeInterval, price: Int, address: String, image: String, created: TimeInterval) {
        Name = name
        Date = date
        Address = address
        Price = price
        Created = created
        Image = image
    }
    
    init(snapshot: DataSnapshot) {
        if let eventDict = snapshot.value as? [String : AnyObject] {
            
            // Event Identifier
            ID = snapshot.key
            
            if let name = eventDict["Name"] as? String {
                Name = name
            } else {
                Name = ""
                print("Invalid 'Name' for Event:", snapshot.key)
            }
            
            if let date = eventDict["Date"] as? TimeInterval {
                Date = date
            } else {
                Date = 0
                print("Invalid 'Date' for Event:", snapshot.key)
            }
            
            if let price = eventDict["Price"] as? Int {
                Price = price
            } else {
                Price = 0
                print("Invalid 'Price' for Event:", snapshot.key)
            }
            
            if let address = eventDict["Address"] as? String {
                Address = address
            } else {
                Address = ""
                print("Invalid 'Address' for Event:", snapshot.key)
            }
            
            if let image = eventDict["Image"] as? String {
                Image = image
            } else {
                Address = ""
                print("Invalid 'Image' for Event:", snapshot.key)
            }
            
            if let created = eventDict["Created"] as? TimeInterval {
                Created = created
            } else {
                Created = 0
                print("Invalid 'Created' for Event:", snapshot.key)
            }
        } else {
            print("Invalid Event:", snapshot.key)
            Name = ""
            Date = 0
            Price = 0
            Address = ""
            Image = ""
            Created = 0 // timestamp
        }
    }
    
    static func isValidEvent(snapshot: DataSnapshot ) -> Bool {
        if let _ = snapshot.value as? [String : AnyObject] {
            return true
        }
        return false
    }
}

