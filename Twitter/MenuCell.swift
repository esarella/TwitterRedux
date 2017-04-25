//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class MenuCell: UITableViewCell {

    @IBOutlet weak var menuTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            let backgroundView = UIView()
            backgroundView.backgroundColor = FlatNavyBlue()
            self.selectedBackgroundView = backgroundView
        } else {
        self.backgroundColor = FlatNavyBlueDark()
        }

    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            menuTitleLabel.textColor = UIColor.white

            let background = UIView()
            background.backgroundColor = FlatNavyBlue()
            self.selectedBackgroundView = background

        } else {
            menuTitleLabel.textColor = UIColor.white
        }
    }

}
