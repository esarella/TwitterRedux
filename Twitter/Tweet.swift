//
//  Tweet.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class Tweet: NSObject {

    var user: User?
    var text: String?
    var timestamp: Date?
    var timestampString: String?
    var timestampLongString: String?

    var IDString: String?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var retweeted: Bool = false
    var favorited: Bool = false
    var truncated: Bool = false
    var inReplyToStatusIDString: String?
    var retweetData: Tweet?
    var entities: Entities?

    var displayRelativeDate: String {
        if let timestamp = timestamp {
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.allowedUnits = [.year, .month, .weekOfYear, .day, .hour, .minute, .second]
            dateComponentsFormatter.maximumUnitCount = 1
            dateComponentsFormatter.unitsStyle = .abbreviated
            return dateComponentsFormatter.string(from: timestamp, to: Date()) ?? ""
        }
        return ""
    }

    init(dictionary: NSDictionary) {
        user = User(dictionary: dictionary[TweetParams.user] as! NSDictionary)
        text = dictionary[TweetParams.text] as? String

        if let timestampStr = dictionary[TweetParams.timestamp] as? String {

            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = dateFormatter.date(from: timestampStr)

            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            timestampString = timestamp == nil ? "" : dateFormatter.string(from: timestamp!)

            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            timestampLongString = timestamp == nil ? "" : dateFormatter.string(from: timestamp!)
        }

        IDString = dictionary[TweetParams.tweetIDString] as? String
        retweetCount = (dictionary[TweetParams.retweetCount] as? Int) ?? 0
        favoritesCount = (dictionary[TweetParams.favoritesCount] as? Int) ?? 0
        retweeted = (dictionary[TweetParams.retweeted] as? Bool) ?? false
        favorited = (dictionary[TweetParams.favorited] as? Bool) ?? false
        truncated = (dictionary[TweetParams.truncated] as? Bool) ?? false

        inReplyToStatusIDString = dictionary[TweetParams.inReplyToStatusID] as? String

        if let retweetedStatus = dictionary[TweetParams.retweetedStatus] as? NSDictionary {
            retweetData = Tweet(dictionary: retweetedStatus)
        }

        if let entitiesDictionary = dictionary[TweetParams.entities] as? NSDictionary {
            entities = Entities(dictionary: entitiesDictionary)
        }
    }

    init(text: String, user: User, timestamp: Date) {
        self.user = user
        self.text = text
        self.timestamp = timestamp

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        timestampString = dateFormatter.string(from: timestamp)
    }

    func didFavorited(success: @escaping (NSDictionary, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        TwitterClient.sharedInstance.postFavorite(tweetID: IDString!, success: success, failure: failure)
    }

    func didUnfavorited(success: @escaping (NSDictionary, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        TwitterClient.sharedInstance.postUnfavorite(tweetID: IDString!, success: success, failure: failure)
    }

    func didRetweeted(success: @escaping (Tweet, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        TwitterClient.sharedInstance.postRetweet(tweetID: IDString!, success: success, failure: failure)
    }

    func didUnretweeted(tweetID: String, success: @escaping (Tweet, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        TwitterClient.sharedInstance.postUnretweet(tweetID: tweetID, success: success, failure: failure)
    }

    func getTweetInfo(success: @escaping (Tweet) -> Void, failure: @escaping (Error) -> Void) {
        TwitterClient.sharedInstance.getTweetInfo(tweetID: IDString!, success: success, failure: failure)
    }

    func getTweetInfoWithRetweet(tweetID: String, includeMyRetweet: Bool, success: @escaping (NSDictionary) -> Void, failure: @escaping (Error) -> Void) {
        TwitterClient.sharedInstance.getTweetInfoWithRetweet(tweetID: tweetID, includeMyRetweet: includeMyRetweet, success: success, failure: failure)
    }

    class func tweetsWithArray(_ dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()

        for dictionary in dictionaries {
            tweets.append(Tweet(dictionary: dictionary))
        }

        return tweets
    }
}