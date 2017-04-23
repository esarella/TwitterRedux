//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import Foundation
import UIKit

class AccountCell: UITableViewCell {

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!

    var account: Account! {
        didSet {
            if let user = account.user {

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

                nameLabel.text = user.name
                screenNameLabel.text = "@\(user.screenName!)"
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bannerImageView.alpha = 0.7
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3.0
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
