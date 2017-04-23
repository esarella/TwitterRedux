# Project 3 - *Twitter*

**Twitter** is a basic twitter app to read and compose tweets from the [Twitter API](https://apps.twitter.com/).

Time spent: **22** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can sign in using OAuth login flow.
- [X] User can view last 20 tweets from their home timeline.
- [X] The current signed in user will be persisted across restarts.
- [X] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.  In other words, design the custom cell with the proper Auto Layout settings.  You will also need to augment the model classes.
- [X] User can pull to refresh.
- [X] User can compose a new tweet by tapping on a compose button.
- [X] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.

The following **optional** features are implemented:

- [X] When composing, you should have a countdown in the upper right for the tweet limit.
- [X] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [X] Retweeting and favoriting should increment the retweet and favorite count.
- [X] User should be able to un-retweet and unfavorite and should decrement the retweet and favorite count.
- [X] Replies should be prefixed with the username and the reply_id should be set when posting the tweet,
- [X] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

The following **additional** features are implemented:

- [X] Error messaging implemented with RKDropdownAlert
- [X] Chameleon frameworks color Scheme
- [X] Used Twitter Brand Resources from https://brand.twitter.com/en.html


Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Debugging in closures is very Hard. Had to chnage my programming style to not use closures to fix my bugs.
2. LayoutConstraints were tricky and spent a lot of my time fixing them

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/QgeLNma.gif' title='Twitter Walkthrough' width='' alt='Twitter Walkthrough' />
<img src='http://i.imgur.com/9ssxdKg.gif' title='Feed Refresh' width='' alt='Feed Refresh' />
<img src='http://i.imgur.com/RwfErW4.gif' title='Live Refresh' width='' alt='Live Refresh' />
<img src='http://i.imgur.com/jsppSJo.gif' title='Retweets' width='' alt='Retweets />
<img src='http://i.imgur.com/DztfBHg.gif' title='Errors messaging' width='' alt='Errors messaging' />
<img src='http://i.imgur.com/5BMCTyt.gif' title='Sign out and Signin' width='' alt='Sign out and Signin' />


GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright [2017] [Emmanuel Sarella]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
