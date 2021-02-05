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
        
        //Super basic. A builder or service might be helpful for more complex logic and cards
        
        //This aproach makes it easy to change order and AB test
        /*
         
         if (ABTest.shared.getTest(1).variant == 0) {
            //add some card or change order
         } else {
         
         }
         */
        self.tableItems.append(.reservationBasics)

        if (reservation.restaurant.hasAddress()) {
            self.tableItems.append(.address)
        }
        
        if (!reservation.restaurant.dishes.isEmpty) {
            self.tableItems.append(.review)
        }
    }
}
