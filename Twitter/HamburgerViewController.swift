//
//  HamburgerViewController.swift
//  Twitter
//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTopMarginConstraint: NSLayoutConstraint!

    var currentUser: User!
    var originalLeftMargin: CGFloat!
    var isMenuViewOpen = false

    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            self.addChildViewController(menuViewController)
            menuViewController.view.frame = menuView.bounds
            menuView.addSubview(menuViewController.view)
            menuViewController.didMove(toParentViewController: self)
        }
    }

    var activeViewController: UIViewController! {
        didSet(oldVC) {
            view.layoutIfNeeded()
            isMenuViewOpen = false

            if oldVC != nil {
                oldVC.willMove(toParentViewController: nil)
                oldVC.view.removeFromSuperview()
                oldVC.didMove(toParentViewController: nil)
            }

            addChildViewController(activeViewController)
            activeViewController.view.frame = contentView.bounds
            contentView.addSubview(activeViewController.view)
            activeViewController.didMove(toParentViewController: self)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
                self.leftMarginConstraint.constant = 0
                self.contentView.alpha = 1.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)

        if sender.state == .began {
            if !isMenuViewOpen && velocity.x > 0 {
                originalLeftMargin = leftMarginConstraint.constant
            } else if isMenuViewOpen && velocity.x < 0 {
                originalLeftMargin = leftMarginConstraint.constant
            }
        } else if sender.state == .changed {
            if !isMenuViewOpen && velocity.x > 0 {
                leftMarginConstraint.constant = originalLeftMargin + translation.x
                let a = CGFloat(-0.0028)
                let b = CGFloat(0.9902)
                let alphaValue = a * translation.x + b;
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
                    self.contentView.alpha = alphaValue
                }, completion: nil)
                
            } else if isMenuViewOpen && velocity.x < 0 {
                leftMarginConstraint.constant = originalLeftMargin + translation.x
                
                let a = CGFloat(0.0028)
                let b = CGFloat(0.9902)
                let alphaValue = a * translation.x + b;
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
                    self.contentView.alpha = alphaValue
                }, completion: nil)

            }
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
                if !self.isMenuViewOpen && velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 180
                    self.contentView.alpha = 0.8
                    self.isMenuViewOpen = true
                } else {
                    self.leftMarginConstraint.constant = 0
                    self.contentView.alpha = 1.0
                    self.isMenuViewOpen = false
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
