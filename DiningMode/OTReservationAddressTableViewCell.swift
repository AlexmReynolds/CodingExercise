//
//  OTReservationAddressTableViewCell.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/1/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class OTReservationAddressTableViewCell: UITableViewCell {
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var streetLabel: UILabel!//TODO: need to make auto shrink for long addresses
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    private var restaurant : Restaurant? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        self.wrapperView.layer.cornerRadius = 4.0
        self.wrapperView.clipsToBounds = true
        self.directionsButton.setTitle(NSLocalizedString("Directions", comment: "directions button title"), for: .normal)
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.mapView.isUserInteractionEnabled = false
        
        self.streetLabel.font = OTTheme.titleFont()
        self.streetLabel.textColor = OTTheme.cardTitleColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //TODO: what about users who don't use apple maps? Maybe check if google maps is installed first, if not then use apple. Also also add a long press to address to show a copy menu so the user can copy the address might be nice for people using Uber or something. Uber API might be cool.
    @IBAction func directionsTapped(_ sender: Any) {
        guard let restaurant = self.restaurant else {
            return
        }        
        
        let placeMark = MKPlacemark(coordinate: restaurant.location.coordinate, postalAddress: restaurant.postalAddress())
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = restaurant.name
        
        let regionDistance:CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegion(center: restaurant.location.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        mapItem.openInMaps(launchOptions: options)
    }
}

extension OTReservationAddressTableViewCell : OTDiningModeCardCell {
    func configure(for reservation: Reservation) {
        self.restaurant = reservation.restaurant
        self.streetLabel.text = reservation.restaurant.street

        let formatter = CNPostalAddressFormatter()
        self.streetLabel.text = formatter.string(from: reservation.restaurant.postalAddress())
        
        let regionDistance:CLLocationDistance = 1000//IDK 1000 meters might be fine for now
        let regionSpan = MKCoordinateRegion(center: reservation.restaurant.location.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        
        self.mapView.setRegion(regionSpan, animated: false)
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = reservation.restaurant.location.coordinate
        annotation.title = reservation.restaurant.name
        self.mapView.addAnnotation(annotation)
    }
}
