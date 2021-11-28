//
//  Flickr.PublicFeed.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import Foundation

extension Flickr {
	/// Use this structure only for decoding JSON data received from Flickr server.
	struct PublicFeed: Codable {
		/// Coding key that corresponds to Flickr API
		private enum CodingKeys: String, CodingKey{
			case posts = "items"
		}
		
		/// Array of Flickr posts from the public feed
		let posts: [Flickr.Post]
	}
}
