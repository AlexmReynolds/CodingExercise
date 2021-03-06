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
        self.tableView.isUserInteractionEnabled = true
    }

    func didExpandToFullScreen() {
        let downChevron = UIImage(cgImage: UIImage(named:"chevron_up_icon")!.cgImage!, scale: UIScreen.main.scale, orientation: .down).withRenderingMode(.alwaysTemplate)
        self.chevronImageView.image = downChevron

        //For now do as check on dishes but I assume some restaurants may always have 0 dishes
        if (self.viewModel.reservation.restaurant.dishes.isEmpty) {
            OTAPI.shared.getFullReservations { (result) in
                switch result {
                case .failure(let error)://Could do something here depending on the error
                    print(error)
                case .success(let reservation):
                    
                    let newModel = OTDiningModeViewModel(reservation: reservation)
                    DispatchQueue.main.async {
                        self.updateViewModel(with: newModel)
                    }
                }
            }
        }
    }
    
    func didCollapseToBannerMode() {
        let upChevron = UIImage(named:"chevron_up_icon")?.withRenderingMode(.alwaysTemplate)
        self.chevronImageView.image = upChevron
    }

    //Model could change if we have some service to ping current reservation every hour or so if we have a soon res.
    func updateViewModel(with model: OTDiningModeViewModel) {
        self.viewModel = model
        self.previewLabel.text = model.bannerText
        self.tableDataSource = OTDiningModeTableViewDataSource(reservation: self.viewModel.reservation, items: self.viewModel.tableItems)
        self.tableView.dataSource = self.tableDataSource
        self.tableView.reloadData()
    }
}

//Add some actions as needed for app
extension OTDiningModeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: expand to full screen if needed by design. Either a simple push or an in place expand. In place expand is complex with these UIs. Super easy if just an image. I've only done this once with images vs a view with maps and labels. Easiest would possibly have these cards be child view controllers and just custom present them. Another options would be to take the full screen controller, set it's frame to the frame of the card and do a custom nav transition. This would mean the UI for the card and new controller would have to be pixel perfect. So IDK I'd have to know the design requirements then explore best option. They have Libraries for this as well.
    }
}
