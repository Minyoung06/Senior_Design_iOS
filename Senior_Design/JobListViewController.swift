//
//  JobListViewController.swift
//  Senior_Design
//
//  Created by MinYoung Yang on 10/25/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class Items:NSObject{

    var jobNamesItems:[String] = []
    var jobDateItems:[String] = []
    var jobReportItems:[String] = []
    var jobTeeItems:[String] = []
    
    let docRef = Firestore.firestore()
       .collection("JobShiftDatabase")
       .whereField("caddie", isEqualTo: Auth.auth().currentUser?.uid ?? "")

    func getFBData() {


        docRef.getDocuments{
            (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }

            else{
                print("in Here!")
                for document in querySnapshot!.documents {

                    let dataDescription = document.data()
                    guard let golfClub = dataDescription["golfClub"] else { return }
                    self.jobNamesItems.append(golfClub as? String ?? "")
                    guard let date = dataDescription["date"] else { return }
                    self.jobDateItems.append(date as? String ?? "")
                    guard let reportTime = dataDescription["reportTime"] else { return }
                    self.jobReportItems.append(reportTime as? String ?? "")
                    guard let teeTime = dataDescription["teeTime"] else { return }
                    self.jobTeeItems.append(teeTime as? String ?? "")

                }   // for end
                print("in getData(): ",self.jobTeeItems)
            }   //else end
        }   //docRef.getDocuments end
    }


}

class JobListViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    private var jobNamesItems:[String] = []
    private var jobDateItems:[String] = []
    private var jobReportItems:[String] = []
    private var jobTeeItems:[String] = []

    let docRef = Firestore.firestore()
       .collection("JobShiftDatabase")
       .whereField("caddie", isEqualTo: Auth.auth().currentUser?.uid ?? "")

    func getFBData() {


        docRef.getDocuments{
            (querySnapshot, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }

            else{
                print("in Here!")
                for document in querySnapshot!.documents {

                    let dataDescription = document.data()
                    guard let golfClub = dataDescription["golfClub"] else { return }
                    self.jobNamesItems.append(golfClub as? String ?? "")
                    guard let date = dataDescription["date"] else { return }
                    self.jobDateItems.append(date as? String ?? "")
                    guard let reportTime = dataDescription["reportTime"] else { return }
                    self.jobReportItems.append(reportTime as? String ?? "")
                    guard let teeTime = dataDescription["teeTime"] else { return }
                    self.jobTeeItems.append(teeTime as? String ?? "")

                }   // for end
                print("in getData(): ",self.jobTeeItems)
            }   //else end
        }   //docRef.getDocuments end
    }   //func end
    
    //var menuItems = Items()
    //var menuItems = getFBData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFBData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        let row = indexPath.row
        
        print("in tableView RowAt: ",self.jobTeeItems[row]) //this one is not on the prompt -> it is not get in to this.
        
        cell.ClubName?.text = self.jobNamesItems[row]
        cell.Date?.text = self.jobDateItems[row]
        cell.ReportTime?.text = self.jobReportItems[row]
        cell.TeeTime?.text = self.jobTeeItems[row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("in tableView Section: ",self.jobTeeItems.count)
        
        return self.jobNamesItems.count
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete{
//            array.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//        }
//    }  //not working now

}
 
class JobCell:UITableViewCell{
    
    @IBOutlet weak var ClubName: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var ReportTime: UILabel!
    @IBOutlet weak var TeeTime: UILabel!
    
}

