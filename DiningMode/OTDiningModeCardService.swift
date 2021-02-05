//
//  OTDiningModeCardService.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/1/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTDiningModeCardService {
    
    enum CardType {
        case reservationBasics
        case address
        case review
    }
    //Could simplify and put this on the CardType enum. However, with more cards and more interactions, there may be more abstraction needed in a service.
    class func cellIdentifier(for type:CardType) -> String {
        switch type {
        case .reservationBasics:
            return "OTReservationBasicsTableViewCell"
        case .address:
            return "OTReservationAddressTableViewCell"
        case .review:
            return "OTReservationReviewTableViewCell"

        }
    }
    
    
    class func sectionTitle(for type:CardType) -> String {
        switch type {
        case .reservationBasics:
            return NSLocalizedString("Reservation Info:", comment: "reservation section title")
        case .address:
            return NSLocalizedString("Address:", comment: "address section title")
        case .review:
            return NSLocalizedString("Popular Dishes:", comment: "Popular Dishes section titl")

        }
    }
    
}


protocol OTDiningModeCardCell {
    func configure(for reservation:Reservation)
}
