//
//  TweetDetailCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class TweetDetailCell: UITableViewCell {
    @IBOutlet weak var tweetStatusView: UIView!
    @IBOutlet weak var tweetStatusImageView: UIImageView!
    @IBOutlet weak var tweetStatusLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!

    var tweet: Tweet! {
        didSet {
            if let retweetData = tweet.retweetData {
                tweetStatusView.isHidden = false
                tweetStatusImageView.image = UIImage(named: "Twitter Retweet Action")

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

                timestampLabel.text = retweetData.timestampLongString

                if let mediaURLString = retweetData.entities?.medias?[0].mediaURLString {
                    tweetImageView.setImageWith(URL(string: "\(mediaURLString):large")!)
                } else {
                    tweetImageView.isHidden = true
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

                    timestampLabel.text = tweet.timestampLongString

                    if let mediaURLString = tweet.entities?.medias?[0].mediaURLString {
                        tweetImageView.setImageWith(URL(string: "\(mediaURLString):large")!)
                    } else {
                        tweetImageView.isHidden = true
                    }
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 3.0
        profileImageView.clipsToBounds = true

        tweetImageView.layer.cornerRadius = 5.0
        tweetImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
