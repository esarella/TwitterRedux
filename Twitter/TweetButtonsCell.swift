//
//  TweetButtonsCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

@objc protocol TweetButtonsCellDelegate {
    @objc optional func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, didFavorited value: Bool)

    @objc optional func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, didRetweeted value: Bool)

    @objc optional func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, replyTo tweet: Tweet)
}

class TweetButtonsCell: UITableViewCell {
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!

    var retweetStatus: Bool!
    var favoritedStatus: Bool!
    weak var delegate: TweetButtonsCellDelegate?

    var tweet: Tweet! {
        didSet {
            retweetStatus = tweet.retweeted
            favoritedStatus = tweet.favorited

            if tweet.favorited {
                favoriteButton.setImage(UIImage(named: "Twitter Like Action On"), for: .normal)
                favoriteButton.setImage(UIImage(named: "Twitter Like Action On Pressed"), for: .highlighted)
            } else {
                favoriteButton.setImage(UIImage(named: "Twitter Like Action"), for: .normal)
                favoriteButton.setImage(UIImage(named: "Twitter Like Action Pressed"), for: .highlighted)
            }
            if tweet.retweeted {
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action On"), for: .normal)
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action On Pressed"), for: .highlighted)
            } else {
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action"), for: .normal)
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action Pressed"), for: .highlighted)
            }
        }
    }

    @IBAction func onReplyButtonTap(_ sender: UIButton) {
        delegate?.tweetButtonsCell?(self, replyTo: tweet)
    }

    @IBAction func onRetweetButtonTap(_ sender: UIButton) {
        if !retweetStatus {
            retweetStatus = !retweetStatus
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action On"), for: .normal)
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action On Pressed"), for: .highlighted)
        } else {
            retweetStatus = !retweetStatus
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action"), for: .normal)
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action Pressed"), for: .highlighted)
        }
        delegate?.tweetButtonsCell?(self, didRetweeted: retweetStatus)
    }

    @IBAction func onFavoriteButtonTap(_ sender: UIButton) {
        if !favoritedStatus {
            favoritedStatus = !favoritedStatus
            favoriteButton.setImage(UIImage(named: "Twitter Like Action On"), for: .normal)
            favoriteButton.setImage(UIImage(named: "Twitter Like Action On Pressed"), for: .highlighted)
        } else {
            favoritedStatus = !favoritedStatus
            favoriteButton.setImage(UIImage(named: "Twitter Like Action"), for: .normal)
            favoriteButton.setImage(UIImage(named: "Twitter Like Action Pressed"), for: .highlighted)
        }
        delegate?.tweetButtonsCell?(self, didFavorited: favoritedStatus)
    }

}
