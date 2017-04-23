//
//  LoginViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import RKDropdownAlert

class LoginViewController: UIViewController {

    var currentUser: User!

    @IBAction func onLoginButton(_ sender: UIButton) {
        TwitterClient.sharedInstance.login(
                success: { (user: User) in
                    self.currentUser = user
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                },
                failure: { (error: Error) in
                    RKDropdownAlert.title("Error: \(error.localizedDescription)", message: "Please Try Again Later", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
                }
        )
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let hamburgerVC = segue.destination as! HamburgerViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuNavVC = storyboard.instantiateViewController(withIdentifier: "MenuNavigationController") as! UINavigationController
        let menuVC = menuNavVC.viewControllers[0] as! MenuViewController
        menuVC.hamburgerViewController = hamburgerVC
        hamburgerVC.menuViewController = menuNavVC
    }
}
