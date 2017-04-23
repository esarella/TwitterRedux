//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

@objc protocol AccountsViewControllerDelegate {
    @objc optional func accountsViewController(_ accountsViewController: AccountsViewController, addUserAccount: Bool)
    @objc optional func accountsViewController(_ accountsViewController: AccountsViewController, removeUserAccount: Bool, for indexPath: IndexPath)
    @objc optional func accountsViewController(_ accountsViewController: AccountsViewController, switchUserAccount: Bool, at indexPath: IndexPath)
    @objc optional func accountsViewController(_ accountsViewController: AccountsViewController, doneButton tap: Bool)
}

class AccountsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let accountCell = "AccountCell"
    var accounts: [Account]!
    weak var delegate: AccountsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
    }

    fileprivate func configureRowHeight() {
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    @IBAction func onAddButtonTap(_ sender: UIBarButtonItem) {
        delegate?.accountsViewController?(self, addUserAccount: true)
        self.tableView.reloadData()
    }

    @IBAction func onDoneButtonTap(_ sender: UIBarButtonItem) {
        delegate?.accountsViewController?(self, doneButton: true)
    }

    @objc fileprivate func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(userChangedReloadData(notification:)), name: NSNotification.Name(rawValue: "UserAddAccount"), object: nil)

        notificationCenter.addObserver(self, selector: #selector(userChangedReloadData(notification:)), name: NSNotification.Name(rawValue: "UserDeleted"), object: nil)

    }

    // NEW CODES HERE
    @objc fileprivate func userChangedReloadData(notification: Notification) {
        accounts = TwitterClient.sharedInstance.accounts
        self.tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AccountsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: accountCell, for: indexPath) as! AccountCell
        cell.account = accounts[indexPath.row]

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeToDelete(_:)))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(panGestureRecognizer)

        return cell
    }

    @objc fileprivate func swipeToDelete(_ sender: UIPanGestureRecognizer) {
        let superview = sender.view
        let indexPath = tableView.indexPath(for: superview as! UITableViewCell)

        if sender.state == .began {
        } else if sender.state == .changed {
            view.superview?.superview?.shake(count: 3, forDuration: 0.5, withTranslation: -5)
        } else if sender.state == .ended {
            delegate?.accountsViewController?(self, removeUserAccount: true, for: indexPath!)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if User.currentUser?.IDString == accounts[indexPath.row].user?.IDString {
        } else {
            delegate?.accountsViewController?(self, switchUserAccount: true, at: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.25
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.25
    }
}
