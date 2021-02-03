//
//  Reservation.swift
//  DiningMode
//
//  Created by Olivier Larivain on 12/2/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import CoreGraphics
import Contacts
struct PhotoSize {
	public let width: Int
	public let height: Int
	public let uri: String
	
	public init?(uri: String, width: Int?, height: Int?) {
		guard uri.isEmpty == false else {
			return nil
		}
		
		self.uri = uri
		self.height = height ?? Int.max
		self.width = width ?? Int.max
	}
}

struct Photo {
	
	public let photoSizes: [PhotoSize]
	public var photoId: String?
	public var name: String?
	
	public init?(id: String?, name: String?, sizes: [PhotoSize]) {
		guard sizes.count > 0 else {
			return nil
		}
		self.photoId = id
		self.name = name
		self.photoSizes = sizes
	}
	
	public func urlForSize(desiredSize: CGSize) -> String {
		let scale = 1.0 / UIScreen.main.scale
		let desiredWidth = scale * desiredSize.width
		for size in self.photoSizes {
			if CGFloat(size.width) >= desiredWidth {
				return size.uri
			}
		}
		
		return self.photoSizes[self.photoSizes.count - 1].uri
	}
	
}

struct Snippet {
	let content: String
	let range: NSRange
	let highlights: [NSRange]
}

struct Dish {
	let id: String
	let name: String
	
	let photos: [Photo]
	let snippet: Snippet
}

struct Restaurant {
	let id: String
	let name: String
	
	let street: String
	let city: String
	let state: String
	let zip: String
	let country: String
	
	let location: CLLocation
	
	let profilePhoto: Photo?
	let dishes: [Dish]
    
  
}

//helpers
extension Restaurant {
    func hasAddress() -> Bool {
        return (self.street.count > 0 && self.state.count > 0 && self.city.count > 0 && self.zip.count > 0 )

    }
    func postalAddress() -> CNPostalAddress {
        let address = CNMutablePostalAddress()
        address.street = self.street
        address.state = self.state
        address.city = self.city
        address.postalCode = self.zip
        return address
    }
}

struct Reservation {
	
	let restaurant: Restaurant
	
	let utcDate: Date
	let localDate: Date
	
	let partySize: Int
	
	let confirmationMessage: String?
}

extension Reservation {
    func localTimeString(formatter:DateFormatter) -> String {
        formatter.dateFormat = "EEEE MMM dd hh:mm"
        return formatter.string(from: self.localDate)
    }
}

extension Snippet {
    func getAttributedContent() -> NSAttributedString {
        let attr = NSMutableAttributedString(string: self.content, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .regular)])
        for range in self.highlights {
            attr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14.0, weight: .bold), range: range)
        }
        return attr
    }
}
