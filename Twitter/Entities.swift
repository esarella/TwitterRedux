//
//  Entities.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class Entities: NSObject {
    var medias: [Media]?

    init(dictionary: NSDictionary) {
        if let mediasDictionary = dictionary[TweetParams.media] as? [NSDictionary] {
            medias = Media.mediasWithArray(mediasDictionary)
        }
    }
}
