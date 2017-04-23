//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import RKDropdownAlert
import BDBOAuth1Manager

class MenuViewController: UIViewController, ProfileViewControllerDelegate, AccountsViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!

    fileprivate let menuTitles = ["PROFILE", "TIMELINE", "MENTIONS", "SIGN OUT"]
    fileprivate let menuUserCellIdentifier = "MenuUserCell"
    fileprivate let menuCellIdentifier = "MenuCell"

    var currentUser: User? = User.currentUser
    var accounts: [Account]! = TwitterClient.sharedInstance.accounts
    var contentViewControllers: [UIViewController] = []
    var hamburgerViewController: HamburgerViewController!

    fileprivate var profileNavigationController: UIViewController!
    fileprivate var homeNavigationController: UIViewController!
    fileprivate var mentionsNavigationController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        instantiateContentViewControllers()
    }

    fileprivate func instantiateContentViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        profileNavigationController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as! UINavigationController
        homeNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController
        mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "TweetsNavigationController") as! UINavigationController

        contentViewControllers += [profileNavigationController, homeNavigationController, mentionsNavigationController]
        hamburgerViewController.activeViewController = homeNavigationController
    }

    fileprivate func configureRowHeight() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func profileViewController(_ profileViewController: ProfileViewController, accountVC show: Bool) {
        if show {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let accountNavVC = storyboard.instantiateViewController(withIdentifier: "AccountsNavigationController") as! UINavigationController
            let accountVC = accountNavVC.topViewController as! AccountsViewController
            accountVC.accounts = self.accounts
            accountVC.delegate = self

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = -50
                self.hamburgerViewController.activeViewController = accountNavVC
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func accountsViewController(_ accountsViewController: AccountsViewController, doneButton tap: Bool) {
        if tap {
            tableView.reloadData()

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = 50
                self.hamburgerViewController.activeViewController = self.profileNavigationController
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    func accountsViewController(_ accountsViewController: AccountsViewController, addUserAccount: Bool) {

        TwitterClient.sharedInstance.loginWithForceLogin(success: { (user: User) in
            User.currentUser = user
            self.currentUser = user
            self.accounts = TwitterClient.sharedInstance.accounts
            self.tableView.reloadData()

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserAddAccount"), object: nil)

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = 50
                self.hamburgerViewController.activeViewController = self.profileNavigationController
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)

        }, failure: {(error: Error) in
            RKDropdownAlert.title("Failed to Add User", message: error.localizedDescription, backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
        })
    }

    func accountsViewController(_ accountsViewController: AccountsViewController, removeUserAccount: Bool, for indexPath: IndexPath) {
        removingUserAccount(user: accounts[indexPath.row].user)
    }

    func accountsViewController(_ accountsViewController: AccountsViewController, switchUserAccount: Bool, at indexPath: IndexPath) {

        if let accounts = self.accounts {
            User.currentUser = accounts[indexPath.row].user
            self.currentUser = User.currentUser

            if let accessToken = accounts[indexPath.row].accessToken {

                TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)

                self.tableView.reloadData()

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidChanged"), object: nil)

                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.hamburgerViewController.contentViewTopMarginConstraint.constant = 50
                    self.hamburgerViewController.activeViewController = self.profileNavigationController
                    self.hamburgerViewController.contentViewTopMarginConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }

        }
    }

    fileprivate func removingUserAccount(user: User?) {
        if user == nil {
            TwitterClient.sharedInstance.logout()
        } else {
            TwitterClient.sharedInstance.logout(user: user!)
        }

        if TwitterClient.sharedInstance.accounts.count > 0 {
            self.currentUser = User.currentUser
            self.accounts = TwitterClient.sharedInstance.accounts
            self.tableView.reloadData()

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = 50
                self.hamburgerViewController.activeViewController = self.profileNavigationController
                self.hamburgerViewController.contentViewTopMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension MenuViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return menuTitles.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: menuUserCellIdentifier, for: indexPath) as! MenuUserCell
            if let currentUser = self.currentUser {
                cell.currentUser = currentUser
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: menuCellIdentifier, for: indexPath) as! MenuCell
            cell.menuTitleLabel.text = menuTitles[indexPath.row]
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {

            if indexPath.row == 0 {
                let activeNavVC = contentViewControllers[0] as! UINavigationController
                let activeVC = activeNavVC.topViewController as! ProfileViewController
                activeVC.user = currentUser
                activeVC.delegate = self
                hamburgerViewController.activeViewController = activeNavVC
            } else if indexPath.row == 1 {
                let activeNavVC = contentViewControllers[indexPath.row] as! UINavigationController
                let activeVC = activeNavVC.topViewController as! TweetsViewController
                activeVC.timelineType = TimelineType.homeTimeline
                hamburgerViewController.activeViewController = activeNavVC
            } else if indexPath.row == 2 {
                let activeNavVC = contentViewControllers[indexPath.row] as! UINavigationController
                let activeVC = activeNavVC.topViewController as! TweetsViewController
                activeVC.timelineType = TimelineType.mentionsTimeline
                hamburgerViewController.activeViewController = activeNavVC
            } else {
                self.removingUserAccount(user: nil)
            }

        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
