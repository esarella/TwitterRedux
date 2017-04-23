//
//  TweetCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {
    @IBOutlet weak var tweetStatusView: UIView!
    @IBOutlet weak var tweetStatusImage: UIImageView!
    @IBOutlet weak var tweetStatusLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteLabel: UILabel!

    var tweet: Tweet! {
        didSet {
            if let retweetData = tweet.retweetData {
                tweetStatusView.isHidden = false
                tweetStatusImage.image = UIImage(named: "Twitter Retweet Action")

                if let user = tweet.user {
                    tweetStatusLabel.text = "\(user.name!) Retweeted"
                } else {
                    tweetStatusLabel.text = "Retweeted"
                }

                if let originalUser = retweetData.user {
                    nameLabel.text = originalUser.name
                    screenNameLabel.text = "@\(originalUser.screenName!)"
                    tweetTextLabel.text = retweetData.text

                    if let profileImageURL = originalUser.profileImageURL {
                        profileImageView.setImageWith(profileImageURL, placeholderImage: UIImage(named: "DefaultTwitter"))
                    } else {
                        profileImageView.image = UIImage(named: "DefaultTwitter")
                    }
                }

                retweetLabel.text = retweetData.retweetCount == 0 ? "" : "\(retweetData.retweetCount)"
                favoriteLabel.text = retweetData.favoritesCount == 0 ? "" : "\(retweetData.favoritesCount)"
                timestampLabel.text = retweetData.displayRelativeDate

                if retweetData.favorited {
                    favoriteButton.setImage(UIImage(named: "Twitter Like Action On"), for: .normal)
                    favoriteButton.setImage(UIImage(named: "Twitter Like Action On Pressed"), for: .highlighted)
                } else {
                    favoriteButton.setImage(UIImage(named: "Twitter Like Action"), for: .normal)
                    favoriteButton.setImage(UIImage(named: "Twitter Like Action Pressed"), for: .highlighted)
                }

                if retweetData.retweeted {
                    retweetButton.setImage(UIImage(named: "Twitter Retweet Action On"), for: .normal)
                    retweetButton.setImage(UIImage(named: "Twitter Retweet Action On Pressed"), for: .highlighted)
                } else {
                    retweetButton.setImage(UIImage(named: "Twitter Retweet Action"), for: .normal)
                    retweetButton.setImage(UIImage(named: "Twitter Retweet Action Pressed"), for: .highlighted)
                }
            } else {
                tweetStatusView.isHidden = true

                if let user = tweet.user {
                    nameLabel.text = user.name
                    screenNameLabel.text = "@\(user.screenName!)"
                    tweetTextLabel.text = tweet.text

                    if let profileImageURL = user.profileImageURL {
                        profileImageView.setImageWith(profileImageURL, placeholderImage: UIImage(named: "DefaultTwitter"))
                    } else {
                        profileImageView.image = UIImage(named: "DefaultTwitter")
                    }
                }

                retweetLabel.text = tweet.retweetCount == 0 ? "" : "\(tweet.retweetCount)"
                favoriteLabel.text = tweet.favoritesCount == 0 ? "" : "\(tweet.favoritesCount)"
                timestampLabel.text = tweet.displayRelativeDate

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
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 3.0
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
