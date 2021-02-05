//
//  OTRestaurantDishView.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/3/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit
class OTRestaurantDishView : UIView {
    var snippetLabel = UILabel()
    var nameLabel = UILabel()
    var imageView = UIImageView()
    
    var viewModel : OTRestaurantDishViewModel
    
    init(viewModel: OTRestaurantDishViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.setupUI()
        
        //Simple update block. We could use better binding if needed or KVO or the image fetching could be on this view vs the model
        self.viewModel.didUpdateBlock = { [weak self] (model) in
            if let self = self {
                self.imageView.image = model.image
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(self.imageView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.snippetLabel)
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.snippetLabel.translatesAutoresizingMaskIntoConstraints = false

        self.nameLabel.font = OTTheme.titleFont()
        self.snippetLabel.font = OTTheme.subtitleFont()
        
        self.nameLabel.textColor = OTTheme.cardTitleColor()
        self.snippetLabel.textColor = OTTheme.cardSubtitleColor()
        
        self.nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.snippetLabel.numberOfLines = 0
        
        //Add constraints
        self.imageView.heightAnchor.constraint(equalToConstant: 120.0).isActive = true
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:16).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:-16).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant:16).isActive = true

        self.imageView.bottomAnchor.constraint(equalTo: self.nameLabel.topAnchor, constant:-4).isActive = true

        self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:16).isActive = true
        self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:-16).isActive = true

        self.nameLabel.bottomAnchor.constraint(equalTo: self.snippetLabel.topAnchor, constant:-4).isActive = true

        self.snippetLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:16).isActive = true
        self.snippetLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:-16).isActive = true
        
        let bottom = self.snippetLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-16)
        bottom.priority = UILayoutPriority(rawValue: 999)
        bottom.isActive = true
    }
}
