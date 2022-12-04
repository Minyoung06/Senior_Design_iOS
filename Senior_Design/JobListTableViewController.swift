//
//  JobListTableViewController.swift
//  Senior_Design
//
//  Created by MinYoung Yang on 10/28/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class JobListTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var service: Service?
    private var allItems = [JobItems]() {
        didSet {
            DispatchQueue.main.async {
                self.items = self.allItems
            }
        }
    }
    
    var items = [JobItems]() {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        loadData()
    }
    
    func loadData() {
        service = Service()
        service?.get(collectionID:"JobShiftDatabase") { items in
            self.allItems = items
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        
        cell.ClubName?.text = items[indexPath.row].clubName
        cell.Date?.text = items[indexPath.row].Date
        cell.Phone?.text = items[indexPath.row].Phone
        cell.ReportTime?.text = items[indexPath.row].reportTime
        cell.TeeTime?.text = items[indexPath.row].teeTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            let docID = items[indexPath.row].DocumentID
            //print("This is docID: ",docID ?? "")
            
            let docRef = Firestore.firestore()
               .collection("JobShiftDatabase")
            
            docRef.getDocuments { snapshot, err in
                if let err = err {
                    print("Error getting documents: \(err)")
                }
                else {
                    for document in snapshot!.documents {
                        if(docID == document.documentID){
                            //print("This one is same!", document.documentID)
                            document.reference.updateData(["caddie": ""])
                            document.reference.updateData(["accepted": false])
                            print("Document successfully written!")
                        }
                    }
                }
            }
            
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
}


class JobCell: UITableViewCell {
    
    @IBOutlet weak var ClubName: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var ReportTime: UILabel!
    @IBOutlet weak var TeeTime: UILabel!
    @IBOutlet weak var Phone: UILabel!
}
