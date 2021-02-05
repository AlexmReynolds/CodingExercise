//
//  OTReservationBasicsTableViewCell.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/1/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTReservationBasicsTableViewCell: UITableViewCell {
//First card lists the restaurant name, the reservation time, the party size, and includes a picture of the restaurant

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    private lazy var dateFormatter = DateFormatter()//store here so we don't instantiate one every configure. Date formatters are expensive when created
    
    private var heroOverlay = CAGradientLayer()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = UIColor.white
        self.wrapperView.layer.cornerRadius = 4.0
        self.wrapperView.clipsToBounds = true
        self.heroImageView.image = UIImage(named: "location-placeholder")
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        
        self.heroOverlay.colors = [UIColor.clear.cgColor, UIColor(white: 0.0, alpha: 0.8).cgColor]
        self.heroOverlay.startPoint = CGPoint(x:0.5,y:0.4)
        self.heroImageView.layer.addSublayer(self.heroOverlay)
        
        self.firstLabel.font = OTTheme.titleFont()
        self.secondLabel.font = OTTheme.subtitleFont()
        self.firstLabel.textColor = OTTheme.cardTitleColor()
        self.secondLabel.textColor = OTTheme.cardSubtitleColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.heroOverlay.frame = self.heroImageView.bounds
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension OTReservationBasicsTableViewCell : OTDiningModeCardCell {
    func configure(for reservation: Reservation) {
        self.titleLabel.text = reservation.restaurant.name
        
        self.firstLabel.text = reservation.localTimeString(formatter: self.dateFormatter)
        
        let partySizeFormat = NSLocalizedString("Party: %i", comment: "party size label")
        self.secondLabel.text = String(format:partySizeFormat, reservation.partySize)
        let requiredSize = self.heroImageView.bounds.size
        DispatchQueue.global(qos: .background).async {
            reservation.restaurant.profilePhoto?.getImage(desiredSize: requiredSize) { [weak self] (result) in
                //This screen may be dealloced so use weak
                if let self = self {
                    switch result {
                    case .success(let image):
                        DispatchQueue.main.async {
                            self.heroImageView.image = image
                        }
                    default:
                        DispatchQueue.main.async {
                            self.heroImageView.image = UIImage(named: "location-placeholder")
                        }
                        
                        //failed. Could read the error and handle but for now just show some happy placeholder
                    }
                }
            }
        }
        
    }
}
