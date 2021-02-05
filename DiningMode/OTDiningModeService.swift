//
//  OTDiningModeService.swift
//  DiningMode
//
//  Created by Alex Reynolds on 1/30/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import Foundation

class OTDiningModeService {
    static let shared = OTDiningModeService()
    
    //Might need more code in the future so a service to do all this checking and helping might be nice
    func upcomingReservation(completion: @escaping ((Reservation?)->Void)) -> Void {
        
        OTAPI.shared.getPartialReservations { (result) in
            switch result {
            case .failure(let error):
                print("get reservation error:\(error)")
                completion(nil)
            case .success(let reservation):
                completion(reservation)
            }
        }
    }
}
