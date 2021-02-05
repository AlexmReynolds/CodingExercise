//
//  OTTabbarViewController.swift
//  DiningMode
//
//  Created by Alex Reynolds on 1/30/21.
//  Copyright © 2021 OpenTable, Inc. All rights reserved.
//

import UIKit

class OTTabbarViewController: UITabBarController {

    var diningModeViewController : OTDiningModeViewController? = nil
    var isDraggingDiningBanner = false
    var panStartLocation : CGPoint = .zero
    var panLastLocation : CGPoint = .zero

    var bannerHeightConstraint : NSLayoutConstraint? = nil
    
    //Hard coded to 80. Might be better to make dynamic so if the reservation name is longer.
    private let bannerHeight : CGFloat = 80.0
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addDiningModeIfNeeded()
    }
    
    //We may not have a dining view. Future iteration might also want to add expiring the banner if the reservation is old. Also might even check the reservation date is future before adding. Also might add a filter in case we have multiple reservations so we grab the soonest first
    
    //For now I added as a child controller. Depending on the design I might just use a basic view for the banner and then a custom present transition to present the dining mode full screen. IDK there are libs for this as well so maybe a library might be fine. Lot's of ways to do this.
    private func addDiningModeIfNeeded() {
        OTDiningModeService.shared.upcomingReservation { (reservation) in
            if let reservation = reservation {
                DispatchQueue.main.async {
                    let viewModel = OTDiningModeViewModel(reservation:reservation)
                    let diningViewController = OTDiningModeViewController(viewModel:viewModel)
                    self.addChild(diningViewController)
                    self.view.addSubview(diningViewController.view)
                    diningViewController.view.translatesAutoresizingMaskIntoConstraints = false
                    diningViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                    diningViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                    diningViewController.view.bottomAnchor.constraint(equalTo: self.tabBar.safeAreaLayoutGuide.topAnchor).isActive = true
                    self.bannerHeightConstraint = diningViewController.view.heightAnchor.constraint(equalToConstant: self.bannerHeight)
                    self.bannerHeightConstraint?.isActive = true
                    
                    self.diningModeViewController = diningViewController
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.viewWasPanned(_:)))
                    panGesture.cancelsTouchesInView = false
                    panGesture.delegate = self
                    self.view.addGestureRecognizer(panGesture)
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.bannerWasTapped))
                    diningViewController.promoView.addGestureRecognizer(tap)
                }
                
            }
        }
    }
    
    //Optionally we could handle this in the view controller or some navigation helper
    //I do like it here since the dining mode might be able to be opened without a banner.
    @objc private func bannerWasTapped() {
        guard let diningVC = self.diningModeViewController else {
            return
        }
        if (diningVC.view.frame.origin.y + self.bannerHeight == self.tabBar.frame.origin.y) {
            //go to full screen
            self.bannerHeightConstraint?.constant = self.tabBar.frame.origin.y
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()

            } completion: { (finished) in
                diningVC.didExpandToFullScreen()
            }

        } else {//collapse
            self.bannerHeightConstraint?.constant = self.bannerHeight

            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                self.view.layoutIfNeeded()

            } completion: { (finished) in
                diningVC.didCollapseToBannerMode()
            }
        }
    }
    
    //Might be useful to hide the banner as it opens. IE it could collapse and hide or something to create a cleaner dining mode full screen.
    
    @objc private func viewWasPanned(_ gesture:UIPanGestureRecognizer) {
        guard let diningVC = self.diningModeViewController else {
            return
        }
        let location = gesture.location(in: self.view)
        if (self.isDraggingDiningBanner) {
            if (self.panLastLocation != .zero) {
                let diff = self.panLastLocation.y - location.y

                if (diff > 0) {//dragging up
                    if (diningVC.view.frame.origin.y > 0) {//prevent off screen dragging
                        self.bannerHeightConstraint?.constant = diningVC.view.frame.size.height + diff
                    }
                } else {//dragging down
                    if (diningVC.view.frame.origin.y < self.tabBar.frame.origin.y - self.bannerHeight) {//prevent off screen dragging
                        self.bannerHeightConstraint?.constant = diningVC.view.frame.size.height + diff
                    }
                }
            }
        }
        self.panLastLocation = location

    }
}

//Down and dirty. There could be some interaction issues or bugs needed to be fixed due to rapid panning or other untested issue like scroll up down back and forth fast
extension OTTabbarViewController : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let diningVC = self.diningModeViewController else {
            return true
        }
        let location = gestureRecognizer.location(in: self.view)
        let promoViewFrameInWindow = diningVC.promoView.convert(diningVC.promoView.frame, to: self.view)
        
        //For now lets ignore this when it's a pan outside of the banner. This prevents scrolling the dining view from triggering it. There are other ways to do this banner.
        if (promoViewFrameInWindow.contains(location)) {
            return true
        } else {
            return false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let diningVC = self.diningModeViewController, let firstTouch = touches.first else {
            return
        }
        let location = firstTouch.location(in: self.view)
        let promoViewFrameInWindow = diningVC.promoView.convert(diningVC.promoView.frame, to: self.view)
        if (promoViewFrameInWindow.contains(location)) {
            self.isDraggingDiningBanner = true
            self.panStartLocation = location
        } else {
            self.panStartLocation = .zero
            self.isDraggingDiningBanner = false
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let diningVC = self.diningModeViewController else {
            return
        }
        if (self.isDraggingDiningBanner && self.panStartLocation != .zero) {
            let threshhold = self.view.bounds.size.height * 0.4
            if (diningVC.view.frame.origin.y < threshhold) {
                //go to full screen
                self.bannerHeightConstraint?.constant = self.tabBar.frame.origin.y
                self.view.layoutIfNeeded()
            } else {//collapse
                self.bannerHeightConstraint?.constant = self.bannerHeight
                diningVC.didCollapseToBannerMode()
            }
            
        }
        if (diningVC.view.frame.origin.y == 0) {
            diningVC.didExpandToFullScreen()
        }
        self.isDraggingDiningBanner = false
        self.panStartLocation = .zero
    }
}
