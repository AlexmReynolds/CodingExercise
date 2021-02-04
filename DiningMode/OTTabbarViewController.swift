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
    private let bannerHeight : CGFloat = 80.0
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

extension OTTabbarViewController : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let diningVC = self.diningModeViewController else {
            return true
        }
        let location = gestureRecognizer.location(in: self.view)
        let promoViewFrameInWindow = diningVC.promoView.convert(diningVC.promoView.frame, to: self.view)
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
            print("begin drag it")
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
