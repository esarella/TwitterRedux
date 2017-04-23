//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import SVProgressHUD
import SVPullToRefresh
import RKDropdownAlert


enum TimelineType: String {
    case homeTimeline = "Home Timeline"
    case mentionsTimeline = "Mentions Timeline"
    case userTimeline = "User Timeline"
}

class TweetsViewController: UIViewController {

    fileprivate enum SegueIdentifiers {
        static let compose = "ComposeModalSegue"
        static let detail = "DetailPushSegue"
    }

    @IBOutlet weak var tableView: UITableView!
    fileprivate var tweets: [Tweet]?
    fileprivate var currentUser = User.currentUser
    fileprivate var currentProfileUserID: String?
    fileprivate var pastProfileUser: User?

    var profileUser: User?
    var timelineType = TimelineType.homeTimeline

    override func viewDidLoad() {
        super.viewDidLoad()

        configureRowHeight()
        SVProgressHUD.show()

        fetchTweetsWithCompletion {
            SVProgressHUD.dismiss()
        }

        addRefreshControl()
        subscribeToNotifications()

        tableView.addInfiniteScrolling {
            self.insertRowsAtBottom()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.detail {
            guard let destinationViewController = segue.destination as? TweetViewController else { return }
            guard let sender = sender as? TweetCell,
                  let indexPath = tableView.indexPath(for: sender) else { return }

            let tweet = tweets?[indexPath.row]
            destinationViewController.tweet = tweet
        } else if segue.identifier == SegueIdentifiers.compose {
            guard let destinationNavigationController = segue.destination as? UINavigationController,
                  let destinationViewController = destinationNavigationController.topViewController as? ComposeViewController else { return }

            destinationViewController.user = currentUser
            destinationViewController.postTweet = { (tweet: Tweet) in
                self.postTweet(tweet: tweet)
            }
        }
    }

    private func postTweet(tweet: Tweet) {
        tweets?.insert(tweet, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = false
        tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.alpha = 0.5

        SVProgressHUD.show()

        DispatchQueue.global(qos: .background).async {
            let text = tweet.text ?? ""
            TwitterClient.sharedInstance.postStatus(text: text, inReplyToStatusID: nil,
                    success: { (_: Tweet) in
                        self.fetchTweetsWithCompletion {
                            SVProgressHUD.dismiss()
                            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = true
                        }
                    },
                    failure: { (error: Error) in
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            RKDropdownAlert.title("Error: \(error.localizedDescription)", message: "Please Try Again Later", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
                            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = true
                        }
                    }
            )
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TweetsViewController {
    fileprivate func configureRowHeight() {
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    fileprivate func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }

    fileprivate func fetchTweets(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        switch timelineType {
        case .homeTimeline:
            TwitterClient.sharedInstance.homeTimeline(success: success, failure: failure)
        case .mentionsTimeline:
            let parameters = [TweetParams.includeRetweets: 1]
            TwitterClient.sharedInstance.getUserMentions(parameters: parameters, success: success, failure: failure)
        case .userTimeline:
            guard let profileUserID = profileUser?.IDString else { return }
            let parameters: [String: Any] = [TweetParams.userID: profileUserID, TweetParams.includeRetweets: 1]
            TwitterClient.sharedInstance.getUserTimeline(parameters: parameters, success: success, failure: failure)
        }
    }

    fileprivate func fetchTweetsWithCompletion(_ completion: (() -> Void)?) {
        fetchTweets(
                success: { (tweets: [Tweet]) in
                    DispatchQueue.main.async {
                        self.tweets = tweets
                        self.tableView.reloadData()
                        completion?()
                    }
                },
                failure: { (error: Error) in
                    DispatchQueue.main.async {
                        RKDropdownAlert.title("Error: \(error.localizedDescription)", message: "Please Try Again Later", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
                        completion?()
                    }
                }
        )
    }

    @objc fileprivate func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateButtonsSuccess(_:)), name: NSNotification.Name("Successfully Favorited a Tweet"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateButtonsSuccess(_:)), name: NSNotification.Name("Successfully Unfavorited a Tweet"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateButtonsSuccess(_:)), name: NSNotification.Name("Successfully Retweet a Tweet"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateButtonsSuccess(_:)), name: NSNotification.Name("Successfully Unretweet a Tweet"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(userChangedReloadData(_:)), name: NSNotification.Name("UserAddAccount"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(userChangedReloadData(_:)), name: NSNotification.Name("UserDidChanged"), object: nil)
    }

    @objc fileprivate func refreshControlAction(_ refreshControl: UIRefreshControl) {
        fetchTweetsWithCompletion {
            refreshControl.endRefreshing()
        }
    }

    @objc fileprivate func updateButtonsSuccess(_ notification: Notification) {
        fetchTweetsWithCompletion {
        }
    }

    @objc fileprivate func userChangedReloadData(_ notification: Notification) {
        currentUser = User.currentUser
        profileUser = User.currentUser

        fetchTweetsWithCompletion {
        }
    }
}

extension TweetsViewController {
    fileprivate func fetchTweetsForInfiniteLoading(parameters: [String: Any], success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        switch timelineType {
        case .homeTimeline:
            TwitterClient.sharedInstance.homeTimelineWithParameters(parameters: parameters, success: success, failure: failure)
        case .mentionsTimeline:
            var tempParameters = parameters
            tempParameters[TweetParams.includeRetweets] = 1
            TwitterClient.sharedInstance.getUserMentions(parameters: tempParameters, success: success, failure: failure)
        case .userTimeline:
            guard let profileUserID = profileUser?.IDString else { return }
            var tempParameters = parameters
            tempParameters[TweetParams.userID] = profileUserID
            tempParameters[TweetParams.includeRetweets] = 1
            TwitterClient.sharedInstance.getUserTimeline(parameters: tempParameters, success: success, failure: failure)
        }
    }

    fileprivate func insertRowsAtBottom() {
        if let tweets = self.tweets {
            guard let newMaxID = getTimelineMaxID(tweets: tweets) else { return }
            let parameters = [TweetParams.maxID: newMaxID]

            fetchTweetsForInfiniteLoading(parameters: parameters,
                    success: { (newTweets: [Tweet]) in
                        self.tweets = tweets + newTweets
                        self.tableView.reloadData()
                        self.tableView.infiniteScrollingView.stopAnimating()
                    },
                    failure: { (error: Error) in
                        RKDropdownAlert.title("Error", message: "Failed to load more data: \(error.localizedDescription)", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
                        self.tableView.infiniteScrollingView.stopAnimating()
                    }
            )
        } else {
            fetchTweetsWithCompletion {
                self.tableView.infiniteScrollingView.stopAnimating()
            }
        }
    }

    private func getTimelineMaxID(tweets: [Tweet]) -> String? {
        var tempIDArray: [String] = []
        for tweet in tweets {
            if let tweetID = tweet.IDString {
                tempIDArray.append(tweetID)
            }
        }
        guard let maxIDString = tempIDArray.min(), let newMaxID = Int64(maxIDString) else { return nil }
        return "\(newMaxID - 1)"
    }
}

extension TweetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as? TweetCell else {
            fatalError("Failed to dequeue TweetCell.")
        }
        cell.tweet = tweets?[indexPath.row]

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        cell.profileImageView.isUserInteractionEnabled = true
        cell.profileImageView.addGestureRecognizer(tapGestureRecognizer)

        return cell
    }

    @objc private func onTapImage(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        var superview = imageView.superview
        currentProfileUserID = profileUser?.IDString ?? ""
        pastProfileUser = profileUser

        while let isTableViewCell = superview?.isKind(of: UITableViewCell.self),
              isTableViewCell == false {
            superview = superview?.superview
        }

        guard let cell = superview as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }

        guard let tweet = tweets?[indexPath.row] else { return }
        if let retweetData = tweet.retweetData, let originalUser = retweetData.user {
            profileUser = originalUser
        } else {
            profileUser = tweet.user
        }

        if let profileUserID = profileUser?.IDString, currentProfileUserID != profileUserID {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let profileNavigationController = storyboard.instantiateViewController(withIdentifier: "ProfileNavigationController") as? UINavigationController,
                  let profileViewController = profileNavigationController.topViewController as? ProfileViewController else {
                fatalError("Failed to instantiate ProfileViewController")
            }

            profileViewController.user = profileUser
            profileViewController.delegate = self
            navigationController?.pushViewController(profileViewController, animated: true)
        } else {
            view.superview?.superview?.superview?.shake(count: 2.0, forDuration: 0.2, withTranslation: -3.0)
        }
    }
}

extension TweetsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension TweetsViewController: ProfileViewControllerDelegate {
    func profileViewController(_ profileViewController: ProfileViewController, viewWillDisappear: Bool) {
        if viewWillDisappear {
            profileUser = pastProfileUser
        }
    }
}

extension UIView {
    func shake(count: Float? = nil, forDuration duration: Double? = nil, withTranslation translation: Float? = nil) {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        shakeAnimation.autoreverses = true
        shakeAnimation.repeatCount = count ?? 2.0
        shakeAnimation.duration = (duration ?? 0.5) / Double(shakeAnimation.repeatCount)
        shakeAnimation.byValue = translation ?? -5.0
        layer.add(shakeAnimation, forKey: "shake")
    }
}
