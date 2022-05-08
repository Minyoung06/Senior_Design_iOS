//
//  locationSearchTable.swift
//  Senior_Design
//
//  Created by MinYoung Yang on 5/8/22.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil

}
extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
