//
//  Items.swift
//  Senior_Design
//
//  Created by MinYoung Yang on 10/28/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct JobItems {
    let clubName: String?
    let Date: String?
    let Phone: String?
    let reportTime: String?
    let teeTime: String?
    let DocumentID:String?
}

extension JobItems {
    
    static func build(from documents: [QueryDocumentSnapshot]) -> [JobItems] {
        var items = [JobItems]()
        for document in documents {
            items.append(JobItems(clubName: document["golfClubName"] as? String ?? "",
                                  Date: document["date"] as? String ?? "",
                                  Phone: document["phoneNumber"] as? String ?? "",
                                  reportTime: document["reportTime"] as? String ?? "",
                                  teeTime: document["teeTime"] as? String ?? "",
                                  DocumentID: document.documentID))
        }
        
        return items
    }
    
}
    
class Service {
    let database = Firestore.firestore()
    
    func get(collectionID: String,handler: @escaping ([JobItems]) -> Void) {
        database.collection("JobShiftDatabase")
            .whereField("caddie", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .addSnapshotListener{ querySnapshot, err in
                if let error = err {
                    print(error.localizedDescription)
                    handler([])
                }else {
                    handler(JobItems.build(from: querySnapshot?.documents ?? []))
                }
            
            }
        
    }
    
}
