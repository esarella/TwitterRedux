//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

@objc protocol ProfileViewControllerDelegate {
    @objc optional func profileViewController(_ profileViewController: ProfileViewController, accountVC show: Bool)
    @objc optional func profileViewController(_ profileViewController: ProfileViewController, viewWillDisappear: Bool)
}

class ProfileViewController: UIViewController {

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
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var headerInfoView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    weak var delegate: ProfileViewControllerDelegate?
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserHeaderView()
        configureContentView()
        subscribeToNotifications()

        scrollView.contentSize = CGSize(width: nameView.bounds.size.width * 2, height: nameView.bounds.size.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.3
        self.navigationController?.navigationBar.addGestureRecognizer(longPressGesture)
    }

    @objc fileprivate func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(userChangedReloadData(notification:)), name: NSNotification.Name("UserAddAccount"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(userChangedReloadData(notification:)), name: NSNotification.Name("UserDidChanged"), object: nil)
    }

    @objc fileprivate func userChangedReloadData(notification: Notification) {
        user = User.currentUser
        self.view.reloadInputViews()
        configureUserHeaderView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func userButtonTap(_ sender: UIButton) {
        delegate?.profileViewController?(self, accountVC: true)
    }

    func onLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        delegate?.profileViewController?(self, accountVC: true)
    }

    fileprivate func configureUserHeaderView() {
        self.navigationItem.title = user.name

        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName!)"
        descriptionLabel.text = user.tagline
        countTweetsLabel.text = user.tweetsCount == 0 ? "0" : formatNumber(amount: user.tweetsCount)
        countFollowingLabel.text = user.followingsCount == 0 ? "0" : formatNumber(amount: user.followingsCount)
        countFollowersLabel.text = user.followersCount == 0 ? "0" : formatNumber(amount: user.followersCount)

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

        profileImageView.layer.cornerRadius = 5.0
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 3.0
        profileImageView.clipsToBounds = true
    }

    fileprivate func configureContentView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userTweetsVC = storyboard.instantiateViewController(withIdentifier: "TimelineViewController") as! TweetsViewController
        userTweetsVC.profileUser = user
        userTweetsVC.timelineType = TimelineType.userTimeline //TimelineType(rawValue: Constants.TimelineType.userTimeline)

        self.addChildViewController(userTweetsVC)
        userTweetsVC.view.frame = contentView.bounds
        contentView.addSubview(userTweetsVC.view)
        userTweetsVC.didMove(toParentViewController: self)
    }

    func formatNumber(amount: Int) -> String {
        var formattedNumber: String

        switch amount {
        case amount where amount >= 1000000:
            formattedNumber = String(format: "%.1fM", Double(amount) / 1000000)
        case amount where amount >= 10000 && amount < 1000000:
            formattedNumber = String(format: "%.1fK", Double(amount) / 1000)
        case amount where amount >= 1000 && amount < 10000:
            formattedNumber = String(format: "%ld,%.0f", amount / 1000, Double(amount).truncatingRemainder(dividingBy: 1000))
        default:
            formattedNumber = "\(amount)"
        }
        return formattedNumber
    }

    @IBAction func pageControlDidPage(_ sender: UIPageControl) {
        let xOffset = scrollView.bounds.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
        changeBannerImageAlpha()
    }

    fileprivate func changeBannerImageAlpha() {
        let originalAlpha: CGFloat = 1.0
        let endingAlpha: CGFloat = 0.70
        bannerImageView.alpha = originalAlpha - ((originalAlpha - endingAlpha) * scrollView.contentOffset.x / nameView.bounds.size.width)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.profileViewController?(self, viewWillDisappear: true)
    }

}

extension ProfileViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = nameView.bounds.size.width
        let page: Int = Int(round(scrollView.contentOffset.x / pageWidth))
        pageControl.currentPage = page
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        changeBannerImageAlpha()
    }
}
