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
    var dishViews : [OTRestaurantDishView] = []
    override func awakeFromNib() {
        super.awakeFromNib()

        self.wrapperView.layer.cornerRadius = 4.0
        self.wrapperView.clipsToBounds = true
        self.scrollView.delegate = self
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension OTReservationReviewTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPageFloat:CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        let currentPage = Int(currentPageFloat)
        if (self.pageControl.currentPage != currentPage) {
            if (self.dishViews.count > Int(currentPage)) {
                let view = self.dishViews[currentPage]
                view.viewModel.fetchImageIfNeeded()
            }
        }
        self.pageControl.currentPage = currentPage

    }
}
extension OTReservationReviewTableViewCell : OTDiningModeCardCell {
    func configure(for reservation: Reservation) {
        //First clean up any old views
        for view in self.dishViews {
            view.removeFromSuperview()
        }
        self.dishViews = []
        
        
        let pageCount = min(3, reservation.restaurant.dishes.count)
        let dishes = Array(reservation.restaurant.dishes.prefix(pageCount))
        self.pageControl.numberOfPages = pageCount
        self.pageControl.currentPage = 0
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        self.makeDishCards(dishes: dishes)
    }
    
    //Could do some other things like use a stack view. Or this card could show them vertically. Also the snippet is long or short so either we could either use a scrollable text view or size it based on the text. IDK would depend on the designer.
    
    //TODO: need to add tap action maybe. Either here or a delegate method on the view. This could expand the dish review on tapping the card.
    private func makeDishCards(dishes: [Dish]) {
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
            
            if (index == 0) {//start loading the first image. This prevents network traffic if the user never scrolls to dish 2 or 3
                dishModel.fetchImageIfNeeded()
            }
            
            dishView.nameLabel.text = dishModel.name
            dishView.snippetLabel.attributedText = dishModel.highlightedSnippet
            lastDishView = dishView
            self.dishViews.append(dishView)
        }
        
    }
}
