//
//  OTReservationReviewTableViewCell.swift
//  DiningMode
//
//  Created by Alex Reynolds on 2/1/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTReservationReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wrapperView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        self.wrapperView.layer.cornerRadius = 4.0
        self.wrapperView.clipsToBounds = true
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension OTReservationReviewTableViewCell : OTDiningModeCardCell {
    func configure(for reservation: Reservation) {
        let pageCount = min(3, reservation.restaurant.dishes.count)
        let dishes = reservation.restaurant.dishes.prefix(pageCount)
        self.pageControl.numberOfPages = pageCount
        self.pageControl.currentPage = 1
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        var lastDishView : UIView? = nil
        for (index, dish) in dishes.enumerated() {
            let dishModel = OTRestaurantDishViewModel(dish: dish)
            let dishView = OTRestaurantDishView(viewModel: dishModel)
            dishView.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(dishView)
            
            dishView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
            dishView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
            dishView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor).isActive = true
            dishView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor).isActive = true

            if let last = lastDishView {
                dishView.leadingAnchor.constraint(equalTo: last.trailingAnchor).isActive = true
            } else {//is the first view
                dishView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor).isActive = true
            }
            if (index == dishes.count - 1) {//last image
                dishView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor).isActive = true
            }
            
            if (index == 0) {//start loading the first image
                dishModel.fetchImageIfNeeded()
            }
            lastDishView = dishView
        }
        
    }
}
