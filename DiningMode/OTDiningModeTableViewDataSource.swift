//
//  OTDiningModeTableViewDataSource.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/1/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTDiningModeTableViewDataSource : NSObject, UITableViewDataSource {
    var reservation : Reservation
    var items : [OTDiningModeCardService.CardType] = []
    init(reservation: Reservation, items: [OTDiningModeCardService.CardType]) {
        self.reservation = reservation
        self.items = items
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section >= self.items.count) {//a little crash safety
            return nil
        }
        let item = self.items[section]

        return OTDiningModeCardService.sectionTitle(for: item)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section >= self.items.count) {//a little crash safety
            return UITableViewCell()
        }
        let item = self.items[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: OTDiningModeCardService.cellIdentifier(for: item))
        if let castCell = cell as? OTDiningModeCardCell {
            castCell.configure(for:self.reservation)
        }
        return cell!
    }
}
