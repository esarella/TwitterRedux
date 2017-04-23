//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import RKDropdownAlert

class ComposeViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var characterCountBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tweetBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var inReplyView: UIView!
    @IBOutlet weak var nameInViewLabel: UILabel!
    @IBOutlet weak var screenNameInPlaceholderLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!

    var user: User!
    var replyToUser: User!
    var tweet: Tweet!
    var postTweet: ((Tweet) -> Void)?
    let maxCharacter = 140

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName!)"
        if let profileImageURL = user.profileImageURL {
            profileImageView.setImageWith(profileImageURL, placeholderImage: UIImage(named: "DefaultTwitter"))
        } else {
            profileImageView.image = UIImage(named: "DefaultTwitter")
        }

        tweetTextView.becomeFirstResponder()
        tweetBarButtonItem.isEnabled = false
        profileImageView.layer.cornerRadius = 3.0
        profileImageView.clipsToBounds = true
        characterCountBarButtonItem.title = "\(maxCharacter)"
        configurePlaceholder()
    }

    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onTweetButtonTap(_ sender: UIBarButtonItem) {
        if tweetTextView.text.isEmpty {
            showAlert(withMessage: "Tweet cannot be empty")
        } else {
            if replyToUser == nil {
                let newTweet = Tweet(text: tweetTextView.text, user: user, timestamp: Date())
                self.postTweet?(newTweet)
                self.dismiss(animated: true, completion: nil)
            } else {
                let replyToUserScreenName = "@\(replyToUser.screenName!)"

                TwitterClient.sharedInstance.postStatus(text: "\(replyToUserScreenName) \(tweetTextView.text!)", inReplyToStatusID: tweet.IDString!, success: { (tweet: Tweet) in

                    if let replyID = tweet.inReplyToStatusIDString {
                        RKDropdownAlert.title("Success!", message: "ReplyID is \(replyID)\nTap to Dismiss", backgroundColor: ChameleonColors.successBackgroundColor, textColor: ChameleonColors.successTextColor, time: 1, delegate: self)
                    } else {
                        RKDropdownAlert.title("Success!", message: "Tap to Dismiss", backgroundColor: ChameleonColors.successBackgroundColor, textColor: ChameleonColors.successTextColor, time: 1, delegate: self)
                    }
                }, failure: { (error: Error) in
                    RKDropdownAlert.title("Error! \(error.localizedDescription)", message: "Please Try Again Later", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
                })
            }
        }
    }

    fileprivate func showAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func configurePlaceholder() {
        if replyToUser == nil {
            inReplyView.isHidden = true
            screenNameInPlaceholderLabel.isHidden = true
            placeholderLabel.isHidden = false
        } else {
            inReplyView.isHidden = false
            screenNameInPlaceholderLabel.isHidden = false
            placeholderLabel.isHidden = true
            nameInViewLabel.text = replyToUser.name!
            screenNameInPlaceholderLabel.text = "@\(replyToUser.screenName!)"
        }
    }

}

extension ComposeViewController: UITextViewDelegate {

    func textViewDidEndEditing(_ textView: UITextView) {
        if !(textView.hasText) {
            placeholderLabel.isHidden = false
            tweetBarButtonItem.isEnabled = false
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if !(textView.hasText) {
            if replyToUser == nil {
                placeholderLabel.isHidden = false
                tweetBarButtonItem.isEnabled = false
            } else {
                tweetBarButtonItem.isEnabled = false
            }
        } else {
            if replyToUser == nil {
                placeholderLabel.isHidden = true
                tweetBarButtonItem.isEnabled = true
            } else {
                tweetBarButtonItem.isEnabled = true
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = textView.text ?? ""

        guard let textRange = range.range(for: currentText) else {
            return false
        }

        let changedText = currentText.replacingCharacters(in: textRange, with: text)
        let countRemaining = max(0, maxCharacter - changedText.characters.count)
        characterCountBarButtonItem.title = "\(countRemaining)"
        return changedText.characters.count <= maxCharacter
    }
}

extension NSRange {
    func range(for string: String) -> Range<String.Index>? {
        guard location != NSNotFound else {
            return nil
        }

        guard let fromUTFIndex = string.utf16.index(string.utf16.startIndex, offsetBy: location, limitedBy: string.utf16.endIndex) else {
            return nil
        }

        guard let toUTFIndex = string.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: string.utf16.endIndex) else {
            return nil
        }

        guard let fromIndex = String.Index(fromUTFIndex, within: string) else {
            return nil
        }

        guard let toIndex = String.Index(toUTFIndex, within: string) else {
            return nil
        }

        return fromIndex ..< toIndex
    }
}

extension ComposeViewController: RKDropdownAlertDelegate {
    func dropdownAlertWasTapped(_ alert: RKDropdownAlert!) -> Bool {
        return false
    }

    func dropdownAlertWasDismissed() -> Bool {
        self.dismiss(animated: true, completion: nil)
        return true
    }
}
