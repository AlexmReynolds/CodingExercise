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
    
    
}


protocol OTDiningModeCardCell {
    func configure(for reservation:Reservation)
}
