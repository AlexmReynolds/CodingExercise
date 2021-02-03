//
//  OTDiningModeViewModel.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/1/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import Foundation

class OTDiningModeViewModel {
    
    var reservation : Reservation
    var bannerText : String = ""
    var tableItems : [OTDiningModeCardService.CardType] = []
    
    init(reservation: Reservation) {
        self.reservation = reservation
        self.bannerText = reservation.restaurant.name
        
        self.tableItems.append(.reservationBasics)

        if (reservation.restaurant.hasAddress()) {
            self.tableItems.append(.address)
        }
        
        if (!reservation.restaurant.dishes.isEmpty) {
            self.tableItems.append(.review)
        }
    }
}
