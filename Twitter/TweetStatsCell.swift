//
//  TweetStatsCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class TweetStatsCell: UITableViewCell {

    @IBOutlet weak var countRetweetsLabel: UILabel!
    @IBOutlet weak var countLikesLabel: UILabel!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!

    var tweet: Tweet! {
        didSet {
            if let retweetData = tweet.retweetData {
                countRetweetsLabel.text = retweetData.retweetCount == 0 ? "0" : "\(retweetData.retweetCount)"
                countLikesLabel.text = retweetData.favoritesCount == 0 ? "0" : "\(retweetData.favoritesCount)"
            } else {
                countRetweetsLabel.text = tweet.retweetCount == 0 ? "0" : "\(tweet.retweetCount)"
                countLikesLabel.text = tweet.favoritesCount == 0 ? "0" : "\(tweet.favoritesCount)"
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
