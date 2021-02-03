//
//  OTAPI.swift
//  DiningMode
//
//  Created by Alex Reynolds on 1/31/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import Foundation

class OTAPI {
    static let shared = OTAPI()
    private let noJsonFileError = NSError(domain: "com.opentable", code: 400, userInfo: [NSLocalizedDescriptionKey : "No file found"])
    private let assemblerReservationError = NSError(domain: "com.opentable", code: 400, userInfo: [NSLocalizedDescriptionKey : "Cannot assemble Reservation"])

    //TODO: Cache this result locally. Things like dishes don't change often. We will fetch the smaller request more often to ensure time and party haven't changed but this call is only needed once.
    func getFullReservations(completion: @escaping ((Result<Reservation,Error>)->Void)) {
        DispatchQueue.global(qos: .background).async {
            if let jsonData = self.loadJson(named: "FullReservation") {

                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    let assembler = ReservationAssembler()
                    if let reservation = assembler.createReservation(json) {
                        completion(.success(reservation))
                    } else {
                        completion(.failure(self.assemblerReservationError))
                    }
                } catch let error {
                    completion(.failure(error))
                }
                
            } else {
                completion(.failure(self.noJsonFileError))
            }
        }
        
    }
    
    func getPartialReservations(completion: @escaping ((Result<Reservation,Error>)->Void)) {
        DispatchQueue.global(qos: .background).async {
            if let jsonData = self.loadJson(named: "PartialReservation") {

                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                    let assembler = ReservationAssembler()
                    if let reservation = assembler.createReservation(json) {
                        completion(.success(reservation))
                    } else {
                        completion(.failure(self.assemblerReservationError))
                    }
                } catch let error {
                    completion(.failure(error))
                }
                
            } else {
                completion(.failure(self.noJsonFileError))
            }
        }
    }
    
    
    private func loadJson(named: String) -> Data? {
        if let path = Bundle.main.path(forResource: named, ofType: "json")
        {
            
            do {
                let url = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: url)
                return jsonData
                 
            } catch {
                return nil
            }
            
        }
        return nil
    }
}
