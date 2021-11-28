# FlickrPublicFeed

FlickrPublicFeed is an iOS app that uses only native Apple APIs and is built with SwiftUI & Combine. 
It loads the Flickr public feed (no Fclickr API key required) parses the retrieved JSON object and decodes it into Swift structures. The goal is to cache the feed data and to load downloaded images into UI without producing a huge spike.
The app supports searching, sorting and scaling the public feed posts.

## Architecture

FlickrPublicFeed is a classic MVVM app. 
It uses the ViewModel class that manages the Model and makes it representable in View. The decoded JSON obects are stored in the array of Flickr.Post instances (Model).

## Networking

FlickrPublicFeed implements a custom NetworkManager that is used for every networking process. When downloading data, NetworkManager caches it with URLSession.

## Tests

FlickrPublicFeed is covered by tests to make sure that the business logic is bullet-proof and the caching is working as expected.


## SwiftUI

FlickrPublicFeed is in pure Swift UI, the goal is to make UI design and implementation process robust, simple and easily changable. Custom RemoteImage view has been bult on top of NetworkManager caching feature to make sure that an image will be loaded fast.

## Platforms

Currently FlickrPublicFeed runs on iPhone and iPadOS 15.0. 
