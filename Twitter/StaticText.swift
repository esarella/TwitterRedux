//
//  StaticText.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

struct StaticText {
    static let twitterBaseURL: String = "https://api.twitter.com/"
    static let callbackURL: String = "twitterdemosarella://oauth"

    static let consumerKey: String = "Xta54Mr1zYTycOZuDSaGNtbUl"
    static let consumerSecret: String = "xphVOZZq3PPWlH7wHyt0YPcZ3CjA9nOfGVJE5aw8yR0LYEwORb"

    //Alternate keys to overcome twitter API Limits
//    static let consumerKey: String = "Y0SJql28CbzeoOneVmx530Iqn"
//    static let consumerSecret: String = "prv3Xd6fJiRHLNq3xFDpCSkJjFJ2Amqg7h5qzvfsTAR8SqYMa9"

    static let requestTokenUrl: String = "oauth/request_token"
    static let accessTokenUrl: String = "oauth/access_token"
    static let authorizeUrl: String = "oauth/authorize?oauth_token="

    static let getUserDataUrl: String = "1.1/account/verify_credentials.json"
    static let getHomeTimelineUrl: String = "1.1/statuses/home_timeline.json"
    static let getStatusInfoUrl: String = "1.1/statuses/show.json"
    static let getStatusInfoWithMyRetweetUrl: String = "1.1/statuses/show/:id.json"
    static let postStatusUrl: String = "1.1/statuses/update.json"
    static let postFavoritesUrl: String = "1.1/favorites/create.json"
    static let postUnfavoritesUrl: String = "1.1/favorites/destroy.json"
    static let postRetweetUrl: String = "1.1/statuses/retweet/:id.json"
    static let postUnretweetUrl: String = "1.1/statuses/unretweet/:id.json"
    static let getCurrentUserData: String = "1.1/account/verify_credentials.json"
    static let getHomeTimeline: String = "1.1/statuses/home_timeline.json"
    static let getUserTimeline: String = "1.1/statuses/user_timeline.json"
    static let getUserMentions: String = "1.1/statuses/mentions_timeline.json"
    static let getStatusInfo: String = "1.1/statuses/show.json"
    static let getStatusInfoWithMyRetweet: String = "1.1/statuses/show/:id.json"
    static let getUserInfo: String = "1.1/users/show.json"

    static let postStatus: String = "1.1/statuses/update.json"
    static let postFavorites: String = "1.1/favorites/create.json"
    static let postUnfavorites: String = "1.1/favorites/destroy.json"
    static let postRetweet: String = "1.1/statuses/retweet/:id.json"
    static let postUnretweet: String = "1.1/statuses/unretweet/:id.json"

    static let favoritedSuccess: String = "Successfully Favorites a Tweet"
    static let favoritedFailure: String = "Failed to Favorite a Tweet"
    static let unFavoritedSuccess: String = "Successfully Unfavorites a Tweet"
    static let unFavoritedFailure: String = "Failed to Unfavorite a Tweet"
    static let retweetSuccess: String = "Successfully Retweet a Tweet"
    static let retweetFailure: String = "Failed to Retweet a Tweet"
    static let unRetweetSuccess: String = "Successfully Undo a retweet"
    static let unRetweetFailure: String = "Failed to Undo a retweet"

    static let getUserTimelineUrl: String = "1.1/statuses/user_timeline.json"
    static let getUserMentionsUrl: String = "1.1/statuses/mentions_timeline.json"
    static let getUserInfoUrl: String = "1.1/users/show.json"
}
