//
//  OTRestaurantDishView.swift
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

        self.nameLabel.font = UIFont.systemFont(ofSize: 16.0,weight: .medium)
        self.snippetLabel.font = UIFont.systemFont(ofSize: 14.0,weight: .regular)
        
        self.nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        //Add constraints
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:16).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:-16).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant:16).isActive = true

        self.imageView.bottomAnchor.constraint(equalTo: self.nameLabel.topAnchor, constant:16).isActive = true

        self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:16).isActive = true
        self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:-16).isActive = true

        self.nameLabel.bottomAnchor.constraint(equalTo: self.snippetLabel.topAnchor, constant:16).isActive = true

        self.snippetLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant:16).isActive = true
        self.snippetLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:-16).isActive = true
        
        let bottom = self.snippetLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-16)
        bottom.priority = UILayoutPriority(rawValue: 999)
        bottom.isActive = true
    }
}
