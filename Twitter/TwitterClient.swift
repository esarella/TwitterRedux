//
//  TwitterClient.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

enum LoginError: Error {
    case requestTokenNil
    case badURL(String)
}

class TwitterClient: BDBOAuth1SessionManager {

    var loginSuccess: ((User) -> Void)?
    var loginFailure: ((Error) -> Void)?
    var accounts: [Account] = [Account]()

    static let sharedInstance = TwitterClient(baseURL: URL(string: StaticText.twitterBaseURL), consumerKey: StaticText.consumerKey, consumerSecret: StaticText.consumerSecret)!

    class func createDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }

    func login(success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        loginSuccess = success
        loginFailure = failure

        // Clean out the state - remove previous access token/keychain
        deauthorize()

        // Fetch request token & redirect to authorization page
        // to finish login process
        fetchRequestToken(withPath: StaticText.requestTokenUrl, method: "GET", callbackURL: URL(string: StaticText.callbackURL), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in

            if let requestToken = requestToken, let token = requestToken.token {
                let urlString = StaticText.twitterBaseURL + StaticText.authorizeUrl + token
                if let authURL = URL(string: urlString), UIApplication.shared.canOpenURL(authURL) {
                    UIApplication.shared.open(authURL, options: [:], completionHandler: nil)
                } else {
                    self.loginFailure?(LoginError.badURL(urlString))
                }
            } else {
                self.loginFailure?(LoginError.requestTokenNil)
            }
        }) { (error: Error?) in
            self.loginFailure?(error!)
        }
    }

    // Handle login process
    func loginWithForceLogin(success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        loginSuccess = success
        loginFailure = failure

        // Clean out the state - remove previous access token/keychain
        deauthorize()

        // Fetch request token & redirect to authorization page
        // to finish login process
        fetchRequestToken(withPath: StaticText.requestTokenUrl, method: "GET", callbackURL: URL(string: StaticText.callbackURL), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in

            if let requestToken = requestToken, let token = requestToken.token {
                let urlString = StaticText.twitterBaseURL + StaticText.authorizeUrl + token + "&" + TweetParams.forceLogin + "=1"
                if let authURL = URL(string: urlString), UIApplication.shared.canOpenURL(authURL) {
                    UIApplication.shared.open(authURL, options: [:], completionHandler: nil)
                } else {
                    self.loginFailure?(LoginError.badURL(urlString))
                }
            } else {
                self.loginFailure?(LoginError.requestTokenNil)
            }
        }) { (error: Error?) in
            self.loginFailure?(error!)
        }
    }

    // Handle open URL
    func openURL(_ url: URL) {

        let queryString = url.query ?? ""
        let requestToken = BDBOAuth1Credential(queryString: queryString)

        if let requestToken = requestToken {
            fetchAccessToken(withPath: StaticText.accessTokenUrl, method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
                print("Got the access token")
                self.requestSerializer.saveAccessToken(accessToken!)

                self.currentAccount(success: { (user: User) in
                    User.currentUser = user

                    self.addUserToAccount(user: user, accessToken: accessToken!)

                    self.loginSuccess?(user)
                }, failure: { (error: Error) in
                    self.loginFailure?(error)
                })
            }) { (error: Error?) in
                self.loginFailure?(error!)
            }
        } else {
            loginFailure?(LoginError.requestTokenNil)
        }
    }

    func addUserToAccount(user: User, accessToken: BDBOAuth1Credential) {
        var isUserInAccounts = false

        if accounts.count > 0 {
            for account in accounts {
                if account.user?.IDString == user.IDString {
                    isUserInAccounts = true
                }
            }
        }

        if !isUserInAccounts {
            let newAccount = Account(user: user, accessToken: accessToken)
            accounts.append(newAccount)
        }
    }

    func removeUserFromAccount(user: User) {
        if accounts.count > 0 {

            for (index, account) in accounts.enumerated() {
                if account.user?.IDString == user.IDString {
                    accounts.remove(at: index)
                }
            }
        }
    }

    // Handle logout process
    func logout() {
        removeUserFromAccount(user: User.currentUser!)

        if self.accounts.count > 0 {
            User.currentUser = self.accounts[0].user
            let accessToken = self.accounts[0].accessToken


            if let accessToken = accessToken {
                self.deauthorize()
                self.requestSerializer.removeAccessToken()
                self.requestSerializer.saveAccessToken(accessToken)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidChanged"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDeleted"), object: nil)
        } else {
            User.currentUser = nil
            self.requestSerializer.removeAccessToken()
            deauthorize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
        }
    }

    func logout(user: User) {
        removeUserFromAccount(user: user)

        if self.accounts.count > 0 {
            User.currentUser = self.accounts[0].user
            let accessToken = self.accounts[0].accessToken


            if let accessToken = accessToken {
                self.deauthorize()
                self.requestSerializer.removeAccessToken()
                self.requestSerializer.saveAccessToken(accessToken)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidChanged"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDeleted"), object: nil)
        } else {
            User.currentUser = nil
            self.requestSerializer.removeAccessToken()
            deauthorize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogout"), object: nil)
        }
    }

    // Fetch current account user
    func currentAccount(success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        self.get(StaticText.getUserDataUrl, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            let user = User(dictionary: response as! NSDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch home timeline
    func homeTimeline(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        self.get(StaticText.getHomeTimelineUrl, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch home timeline with parameters
    func homeTimelineWithParameters(parameters: [String: Any], success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        self.get(StaticText.getHomeTimelineUrl, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Post statuses/update
    func postStatus(text: String, inReplyToStatusID: String?, success: @escaping (Tweet) -> Void, failure: @escaping (Error) -> Void) {
        var parameters = [TweetParams.status: text]
        if let inReplyToStatusID = inReplyToStatusID {
            parameters[TweetParams.inReplyToStatusID] = inReplyToStatusID
        }

        self.post(StaticText.postStatus, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Post favorite - 200 OK response means it's successful
    func postFavorite(tweetID: String, success: @escaping (NSDictionary, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        let parameters = [TweetParams.tweetID: tweetID]

        self.post(StaticText.postFavorites, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in

            success(response as! NSDictionary, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Unpost favorite - 200 OK response means it's successful
    func postUnfavorite(tweetID: String, success: @escaping (NSDictionary, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        let parameters = [TweetParams.tweetID: tweetID]

        self.post(StaticText.postUnfavorites, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in

            success(response as! NSDictionary, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Post retweet
    func postRetweet(tweetID: String, success: @escaping (Tweet, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        let endpoint = StaticText.postRetweet.replacingOccurrences(of: ":id", with: tweetID)

        self.post(endpoint, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Unpost retweet
    func postUnretweet(tweetID: String, success: @escaping (Tweet, URLResponse?) -> Void, failure: @escaping (Error) -> Void) {
        let endpoint = StaticText.postUnretweet.replacingOccurrences(of: ":id", with: tweetID)

        self.post(endpoint, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch tweet info
    func getTweetInfo(tweetID: String, success: @escaping (Tweet) -> Void, failure: @escaping (Error) -> Void) {
        let parameters = [TweetParams.tweetID: tweetID]

        self.get(StaticText.getStatusInfo, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch tweet info including retweets
    func getTweetInfoWithRetweet(tweetID: String, includeMyRetweet: Bool, success: @escaping (NSDictionary) -> Void, failure: @escaping (Error) -> Void) {
        let parameters = [TweetParams.includeMyRetweet: includeMyRetweet]
        let endpoint = StaticText.getStatusInfoWithMyRetweet.replacingOccurrences(of: ":id", with: tweetID)

        self.get(endpoint, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success(response as! NSDictionary)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch info related to a particular user based on their id_str or screen_name
    func getUserInfo(parameters: [String: Any], success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        self.get(StaticText.getUserInfo, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let user = User(dictionary: response as! NSDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch user current timeline
    func getUserTimeline(parameters: [String: Any]?, success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        self.get(StaticText.getUserTimeline, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
//            let responseCode = (task.response as? HTTPURLResponse)?.statusCode
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch user mentions
    func getUserMentions(parameters: [String: Any]?, success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        self.get(StaticText.getUserMentions, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
//            let responseCode = (task.response as? HTTPURLResponse)?.statusCode
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
}
