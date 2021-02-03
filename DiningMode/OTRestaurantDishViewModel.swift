//
//  OTRestaurantDishViewModel.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/3/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTRestaurantDishViewModel {
    let name : String
    let snippet : String
    let highlightedSnippet : NSAttributedString//cache this since it won't change
    var image : UIImage?
    let photo : Photo?
    var didUpdateBlock : ((OTRestaurantDishViewModel)->Void)? = nil
    
    init(dish: Dish) {
        self.name = dish.name
        self.snippet = dish.snippet.content
        self.image = nil //fetch later
        self.photo = dish.photos.first
        self.highlightedSnippet = dish.snippet.getAttributedContent()
    }
    
    func fetchImageIfNeeded() {
        guard let photo = self.photo else {
            return
        }
        if (self.image == nil) {
            DispatchQueue.global(qos: .background).async {
                photo.getImage(desiredSize: CGSize(width:320.0,height:200.0)) { [weak self] (result) in
                    //This screen may be dealloced so use weak
                    if let self = self {
                        switch result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                self.image = image
                                self.didUpdateBlock?(self)
                            }
                        default:
                            DispatchQueue.main.async {
                                self.image = UIImage(named: "location-placeholder")
                                self.didUpdateBlock?(self)
                            }
                            
                            //failed. Could read the error and handle but for now just show some happy placeholder
                        }
                    }
                }
            }
            
        }
    }
    
}
