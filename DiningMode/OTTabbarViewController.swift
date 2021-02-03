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
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addDiningModeIfNeeded()
    }
    
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
                    self.bannerHeightConstraint = diningViewController.view.heightAnchor.constraint(equalToConstant: 80)
                    self.bannerHeightConstraint?.isActive = true
                    
                    self.diningModeViewController = diningViewController
                    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.viewWasPanned(_:)))
                    panGesture.cancelsTouchesInView = false
                    self.view.addGestureRecognizer(panGesture)
                }
                
            }
        }
    }
    
    @objc func viewWasPanned(_ gesture:UIPanGestureRecognizer) {
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
                    if (diningVC.view.frame.origin.y < self.tabBar.frame.origin.y - 80) {//prevent off screen dragging
                        self.bannerHeightConstraint?.constant = diningVC.view.frame.size.height + diff
                    }
                }
            }
        }
        self.panLastLocation = location

    }


}

extension OTTabbarViewController : UIGestureRecognizerDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let diningVC = self.diningModeViewController, let firstTouch = touches.first else {
            return
        }
        let location = firstTouch.location(in: self.view)
        if (diningVC.view.frame.contains(location)) {
            print("begin drag it")
            self.isDraggingDiningBanner = true
            self.panStartLocation = location
        } else {
            self.panStartLocation = .zero
            self.isDraggingDiningBanner = false
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let diningVC = self.diningModeViewController, let firstTouch = touches.first else {
            return
        }
        let location = firstTouch.location(in: self.view)
        if (self.isDraggingDiningBanner && self.panStartLocation != .zero) {
            let threshhold = self.view.bounds.size.height * 0.4
            if (diningVC.view.frame.origin.y < threshhold) {
                //go to full screen
                self.bannerHeightConstraint?.constant = self.tabBar.frame.origin.y
            } else {//collapse
                self.bannerHeightConstraint?.constant = 80
            }
            
        }
        self.isDraggingDiningBanner = false
        self.panStartLocation = .zero
    }
}
