//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
class UserProfileCell: UITableViewCell {

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var countTweetsLabel: UILabel!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var countFollowingLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var countFollowersLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!

    var user: User! {
        didSet {
            nameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenName!)"
            descriptionLabel.text = user.tagline
            countTweetsLabel.text = user.tweetsCount == 0 ? "0" : "\(user.tweetsCount)"
            countFollowingLabel.text = user.followingsCount == 0 ? "0" : "\(user.followingsCount)"
            countFollowersLabel.text = user.followersCount == 0 ? "0" : "\(user.followersCount)"

            if let bannerURL = user.profileBannerURL {
                bannerImageView.setImageWith(bannerURL)
            } else {
                bannerImageView.backgroundColor = ChameleonColors.successBackgroundColor
            }

            if let profileURL = user.profileImageURL {
                profileImageView.setImageWith(profileURL, placeholderImage: UIImage(named: "DefaultTwitter"))
            } else {
                profileImageView.image = UIImage(named: "DefaultTwitter")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3.0
        profileImageView.clipsToBounds = true

        bannerImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
