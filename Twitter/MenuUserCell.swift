//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import Foundation
import UIKit

class MenuUserCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!

    var currentUser: User! {
        didSet {
            nameLabel.text = currentUser.name
            screenNameLabel.text = currentUser == nil ? "@" : "@\(currentUser.screenName!)"

            if let profileImageURL = currentUser.profileImageURL {
                profileImageView.setImageWith(profileImageURL, placeholderImage: UIImage(named: "DefaultImage"))
            } else {
                profileImageView.image = UIImage(named: "DefaultImage")
            }

            if let bannerURL = currentUser.profileBannerURL {
                bannerImageView.setImageWith(bannerURL)
            } else {
                bannerImageView.backgroundColor = ChameleonColors.successBackgroundColor
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3.0
        profileImageView.clipsToBounds = true

        bannerImageView.alpha = 0.7
        bannerImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
