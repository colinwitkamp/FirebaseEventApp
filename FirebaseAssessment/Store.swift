//
//  Store.swift
//  FirebaseAssessment
//
//  Created by Dev on 7/13/17.
//  Copyright © 2017 Colin. All rights reserved.
//

import Foundation
import Firebase

class Store {
    
    static var ref = Database.database().reference()
    static let storage = Storage.storage()
    
    static var events:[Event] = []
    static var watchAddedHandle:UInt = 0
    static var watchUpdatedHandle:UInt = 0
    static var error = ""
    
    static func loadEvents(callback:@escaping (_ bLoaded: Bool) -> Void, eventAdded: @escaping () -> Void, eventUpdated: @escaping (_ ID: String) -> Void) {
        ref.child("Events").queryOrdered(byChild: "Created").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                events.append(Event(snapshot: child as! DataSnapshot))
            }
            var createdAfer:TimeInterval = 0
            if (events.count > 0) {
                createdAfer = events.last!.Created
            }
            watchAddedEvents(createdAfter: createdAfer, eventAdded: eventAdded)
            watchUpdatedEvents(eventUpdated: eventUpdated)
            
            callback(true); // Loaded
        }, withCancel: { (error) in
            callback(false); // Not loaded
        });
    }
    
    static func watchAddedEvents(createdAfter: TimeInterval, eventAdded: @escaping () -> Void) {
        
        // load only the latest events
        watchAddedHandle = ref.child("Events").queryOrdered(byChild: "Created").queryStarting(atValue: createdAfter + 1).observe(.childAdded, andPreviousSiblingKeyWith: { (snapshot, key) in
            if (Event.isValidEvent(snapshot: snapshot)) {
                events.append(Event(snapshot: snapshot))
                eventAdded()
            }
        }, withCancel: nil)
    }
    
    static func watchUpdatedEvents(eventUpdated: @escaping (_ ID: String) -> Void) {
        
        // load only the latest events
        watchUpdatedHandle = ref.child("Events").queryOrdered(byChild: "Created").observe(.childChanged, andPreviousSiblingKeyWith: { (snapshot, key) in
            if (Event.isValidEvent(snapshot: snapshot)) {
                if let index = events.index(where: { (event) -> Bool in
                    return event.ID == snapshot.key
                }) {
                    if (Event.isValidEvent(snapshot: snapshot)) {
                        events[index] = Event(snapshot: snapshot)
                    } else {
                        events.remove(at: index)
                    }
                    eventUpdated(snapshot.key)
                }
            }
        }, withCancel: nil)
    }
    
    static func saveEvent(event: Event, isNew: Bool, callback: @escaping (_ event: Event?) -> Void) {
        var dicEvent:[String: Any] = [:]
        dicEvent["Name"] = event.Name
        dicEvent["Address"] = event.Address
        dicEvent["Image"] = event.Image
        dicEvent["Price"] = event.Price
        dicEvent["Date"] = event.Date

        if (isNew) {
            dicEvent["Created"] = ServerValue.timestamp()
        }
        
        var ID = ""
        
        if (event.ID == "") {
            ID = ref.child("Events").childByAutoId().key;
        } else {
            ID = event.ID
        }
        
        ref.child("Events").child(event.ID).updateChildValues(dicEvent) { (error, snapshot) in
            if let _ = error {
                callback(nil)
            } else {
                let savedEvent = event
                savedEvent.ID = ID
                callback(event)
            }
        }
    }
    
    static func deleteEvent(ID: String) {
        ref.child("Events").child(ID).removeValue()
    }
    
    static func saveImage(id: String, image: UIImage, callback:@escaping (_ url: URL?) -> Void) {
        let storageRef = storage.reference()
        
        // Create a reference to "mountains.jpg"
        let imageRef = storageRef.child("events/\(id).jpg")
        
        // medium quality
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            let uploadTask = imageRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    callback(nil)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                callback(metadata.downloadURL())
            }
            uploadTask.resume()
        } else {
            callback(nil)
        }
    }
    
    static func newEventKey() -> String {
        return ref.child("Events").childByAutoId().key;
    }
    
    
    
}
