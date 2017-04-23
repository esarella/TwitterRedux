//
//  TweetViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import RKDropdownAlert

class TweetViewController: UIViewController {

    fileprivate enum TweetTableStructure: Int {
        case detail = 0
        case stats = 1
        case buttons = 2
    }

    fileprivate enum CellIdentifiers {
        static let detail = "TweetDetailCell"
        static let stats = "TweetStatsCell"
        static let buttons = "TweetButtonsCell"
    }

    fileprivate enum SegueIdentifiers {
        static let reply = "ReplyModalSegue"
    }

    @IBOutlet weak var tweetTableView: UITableView!

    var tweet: Tweet?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRowHeight()
    }

    private func configureRowHeight() {
        tweetTableView.estimatedRowHeight = 500
        tweetTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.reply {
            guard let destinationNavigationController = segue.destination as? UINavigationController,
                  let destinationViewController = destinationNavigationController.topViewController as? ComposeViewController else {
                fatalError("Failed to instantiate ComposeViewController.")
            }

            destinationViewController.user = User.currentUser
            destinationViewController.replyToUser = tweet?.user
            destinationViewController.tweet = tweet
        }
    }
}

extension TweetViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TweetTableStructure(rawValue:section) else { return 0 }

        switch section {
        case .detail, .buttons:
            return 1
        case .stats:
            if let retweetData = tweet?.retweetData {
                return (retweetData.favoritesCount == 0 && retweetData.retweetCount == 0) ? 0 : 1
            } else {
                return (tweet?.favoritesCount == 0 && tweet?.retweetCount == 0) ? 0 : 1
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TweetTableStructure(rawValue: indexPath.section) else {
            fatalError("Invalid indexPath section passed to cellForRowAt method")
        }

        switch section {
        case .detail:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.detail, for: indexPath) as? TweetDetailCell else {
                fatalError("Failed to dequeue TweetDetailCell.")
            }
            cell.tweet = tweet
            return cell
        case .stats:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.stats, for: indexPath) as? TweetStatsCell else {
                fatalError("Failed to dequeue TweetStatsCell.")
            }
            cell.tweet = tweet
            return cell
        case .buttons:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.buttons, for: indexPath) as? TweetButtonsCell else {
                fatalError("Failed to dequeue TweetButtonsCell.")
            }
            cell.delegate = self
            cell.tweet = tweet
            return cell
        }
    }
}

extension TweetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension TweetViewController: TweetButtonsCellDelegate {

    func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, didFavorited value: Bool) {
        guard let tweet = tweet else { return }

        switch value {
        case true:
            DispatchQueue.global(qos: .background).async {
                tweet.didFavorited(
                        success: { (_: NSDictionary, urlResponse: URLResponse?) in
                            self.successResponse(urlResponse, notificationName: "Successfully Favorited a Tweet")
                        },
                        failure: { (error: Error) in
                            self.failureResponse(error: "Failed to Favorite Tweet with Error: \(error.localizedDescription)", doReloadTable: true)
                        }
                )
            }
        case false:
            DispatchQueue.global(qos: .background).async {
                tweet.didUnfavorited(
                        success: { (_: NSDictionary, urlResponse: URLResponse?) in
                            self.successResponse(urlResponse, notificationName: "Successfully Unfavorited a Tweet")
                        },
                        failure: { (error: Error) in
                            self.failureResponse(error: "Failed to Unfavorite Tweet with Error: \(error.localizedDescription)", doReloadTable: true)
                        }
                )
            }
        }
    }

    func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, didRetweeted value: Bool) {
        guard let tweet = tweet else { return }

        switch value {
        case true:
            DispatchQueue.global(qos: .background).async {
                tweet.didRetweeted(
                        success: { (_: Tweet, urlResponse: URLResponse?) in
                            self.successResponse(urlResponse, notificationName: "Successfully Retweet a Tweet")
                        },
                        failure: { (error: Error) in
                            self.failureResponse(error: "Failed to Retweet Tweet with Error: \(error.localizedDescription)", doReloadTable: true)
                        }
                )
            }
        case false:
            var originalTweetIDStr = ""

            if !tweet.retweeted {
                failureResponse(error: "You Have Not Retweeted This Tweet", doReloadTable: true)
            } else {
                originalTweetIDStr = tweet.retweetData == nil ? (tweet.IDString ?? "") : (tweet.retweetData?.IDString ?? "")
            }

            DispatchQueue.global(qos: .background).async {
                tweet.getTweetInfoWithRetweet(tweetID: originalTweetIDStr, includeMyRetweet: true,
                        success: { (dictionary: NSDictionary) in
                            guard let currentUserRetweet = dictionary[TweetParams.currentUserRetweet] as? NSDictionary,
                                  let retweetID = currentUserRetweet[TweetParams.tweetIDString] as? String else {
                                self.failureResponse(error: "Current User Retweet Not Returned", doReloadTable: true)
                                return
                            }

                            tweet.didUnretweeted(tweetID: retweetID,
                                    success: { (_: Tweet, urlResponse: URLResponse?) in
                                        self.successResponse(urlResponse, notificationName: "Successfully Unretweet a Tweet")
                                    },
                                    failure: { (error: Error) in
                                        self.failureResponse(error: "Failed to Unretweet Tweet with Error: \(error.localizedDescription)", doReloadTable: true)
                                    }
                            )
                        },
                        failure: { (error: Error) in
                            self.failureResponse(error: "Failed to get Retweet Info with Error: \(error.localizedDescription)", doReloadTable: true)
                        }
                )
            }
        }
    }

    func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, replyTo tweet: Tweet) {
        performSegue(withIdentifier: SegueIdentifiers.reply, sender: nil)
    }
}

extension TweetViewController {
    fileprivate func failureResponse(error: String?, doReloadTable: Bool) {
        DispatchQueue.main.async {
            RKDropdownAlert.title("Error", message: error ?? "", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
            if doReloadTable {
                self.tweetTableView.reloadData()
            }
        }
    }

    fileprivate func successResponse(_ response: URLResponse?, notificationName: String) {
        guard let responseCode = (response as? HTTPURLResponse)?.statusCode, responseCode == 200 else {
            failureResponse(error: "Response status code is not 200!", doReloadTable: true)
            return
        }

        tweet?.getTweetInfo(
                success: { (newTweet: Tweet) in
                    DispatchQueue.main.async {
                        self.tweet = newTweet
                        self.tweetTableView.reloadData()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil, userInfo: nil)
                    }
                },
                failure: { (error: Error) in
                    self.failureResponse(error: "Failed to Refresh Tweet: \(error.localizedDescription)", doReloadTable: false)
                }
        )
    }
}
