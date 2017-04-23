//
// Created by Emmanuel Sarella on 4/23/17.
// Copyright (c) 2017 Emmanuel Sarella. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

class Account: NSObject {
    var user: User?
    var accessToken: BDBOAuth1Credential?
    var dictionary: NSDictionary?

    init(user: User, accessToken: BDBOAuth1Credential) {
        self.user = user
        self.accessToken = accessToken
    }
}
