//
//  OTDiningModeViewController.swift
//  DiningMode
//
//  Created by Alex Reynolds on 1/30/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTDiningModeViewController: UIViewController {
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    
    var viewModel : OTDiningModeViewModel
    var tableDataSource : OTDiningModeTableViewDataSource
    
    init(viewModel: OTDiningModeViewModel) {
        self.viewModel = viewModel
        self.tableDataSource = OTDiningModeTableViewDataSource(reservation: self.viewModel.reservation, items: self.viewModel.tableItems)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.previewLabel.textColor = UIColor.white
        self.chevronImageView.tintColor = UIColor.white
        self.chevronImageView.image = UIImage(named:"chevron_up_icon")?.withRenderingMode(.alwaysTemplate)
        self.previewLabel.text = self.viewModel.bannerText
        
        self.tableView.register(UINib(nibName: "OTReservationBasicsTableViewCell", bundle: nil) , forCellReuseIdentifier: "OTReservationBasicsTableViewCell")
        self.tableView.register(UINib(nibName: "OTReservationAddressTableViewCell", bundle: nil) , forCellReuseIdentifier: "OTReservationAddressTableViewCell")
        self.tableView.register(UINib(nibName: "OTReservationReviewTableViewCell", bundle: nil) , forCellReuseIdentifier: "OTReservationReviewTableViewCell")
        self.tableView.dataSource = self.tableDataSource
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 120.0
    }

    

    func updateViewModel(with model: OTDiningModeViewModel) {
        self.viewModel = model
        self.previewLabel.text = model.bannerText
        self.tableDataSource = OTDiningModeTableViewDataSource(reservation: self.viewModel.reservation, items: self.viewModel.tableItems)
    }
}

extension OTDiningModeViewController : UITableViewDelegate {
    
}
