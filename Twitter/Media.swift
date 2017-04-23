//
//  Media.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class Media: NSObject {
    var ID: Int?
    var IDString: String?
    var mediaURLString: String?
    var mediaURL: URL?
    var type: String?

    init(dictionary: NSDictionary) {
        ID = dictionary[TweetParams.mediaID] as? Int
        IDString = dictionary[TweetParams.mediaIDString] as? String
        type = dictionary[TweetParams.type] as? String

        if let mediaURLString = dictionary[TweetParams.mediaURL] as? String {
            self.mediaURLString = mediaURLString
            mediaURL = URL(string: mediaURLString)
        }
    }

    class func mediasWithArray(_ dictionaries: [NSDictionary]) -> [Media] {
        var medias = [Media]()

        for dictionary in dictionaries {
            medias.append(Media(dictionary: dictionary))
        }

        return medias
    }
}
