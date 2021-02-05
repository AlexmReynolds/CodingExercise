//
//  OTReservationImageHelpers.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/2/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

extension Photo {
    
    //Super basic and straight forward image loading. We assume the caller calls on a bkg thread but we could add that here to prevent bad calling
    func getImage(desiredSize: CGSize, completion: @escaping ((Result<UIImage, Error>)->Void)) -> Void {
        if let url = URL(string:self.urlForSize(desiredSize: desiredSize)) {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    completion(.success(image))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    let error = NSError(domain: "com.opentable", code: 400, userInfo: [NSLocalizedDescriptionKey: "No photo"])
                    completion(.failure(error))
                }
            }.resume()

        } else {
            let error = NSError(domain: "com.opentable", code: 400, userInfo: [NSLocalizedDescriptionKey: "No photo"])
            completion(.failure(error))
        }
    }
}
