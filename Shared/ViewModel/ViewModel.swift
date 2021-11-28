//
//  ViewModel.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import SwiftUI
import UIKit
import Combine

class ViewModel: ObservableObject, PostSortable {
	@Published var posts: [Flickr.Post] = []
	@Published var tags: String = ""
	@Published var networkStatus: NetworkStatus = .init()
	@Published var error: Error?
		
	/// Posts sort ordering. The value is being persisted in UserDefaults because of @AppStorage property wrapper
	@AppStorage("sortOrder") var sortOrder: SortOrder = .publishingDate {
		didSet {
			posts = Self.sort(posts, by: sortOrder)
		}
	}

	// Flickr public feed URL with neccessary options set
	private let publicFeedURLString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"
	
	/// A subscriber object that listens to the network status changes.
	private var subscriber: AnyCancellable?
	
	static let shared: ViewModel = .init()
	
	private init() {
		subscriber = NetworkManager.shared.$status.sink { [weak self] status in
			self?.networkStatus = status
		}
	}
	
	deinit {
		subscriber?.cancel()
	}
	
	
	/// Refreshes the view model state by downloading a fresh Flickr feed data respecting tags that the user might specified already.
	func refresh() {
		// construct the URL containing request for tags if any
		let resolvedURLString = tags.isEmpty ? publicFeedURLString : publicFeedURLString + "&tags=\(tags)"
		guard let publicFeedURL = URL(string: resolvedURLString) else {
			// do nothing because this happens when user types invalid chars to the search bar,
			// so the URL becomes invalid
			return
		}
		
		// download Flickr publick feed
		NetworkManager.shared.retrieveData(from: publicFeedURL, { [weak self] data, error in
			guard let data = data else {
				if let error = error {
					self?.error = error
				}
				return
			}
			
			do {
				if let newPosts = try self?.posts(from: data) {
					
					// update the state on the main queue
					DispatchQueue.main.async { [weak self] in
						self?.posts = newPosts
					}
				}
			} catch {
				self?.error = error
			}
		})
	}
	
	
	/// Decodes Flickr posts from a new data feed.
	/// - Parameter data: Flickr data feed representing array of posts
	/// - Returns: an array with decoded Flickr posts
	func posts(from data: Data) throws -> [Flickr.Post] {
		// decode data into Flickr posts
		do {
			// set up the json decoder
			let jsonDecoder = JSONDecoder()
			jsonDecoder.dateDecodingStrategy = .iso8601
			
			// try to decode json from the aquired data
			let publicFeed = try jsonDecoder.decode(Flickr.PublicFeed.self, from: data)
			
			return Self.sort(publicFeed.posts, by: self.sortOrder)
		} catch {
			throw NetworkError.invalidResponse
		}
	}
	
		
	
	// MARK: - View Models
		
	/// Converts a data into a human readable string.
	/// - Parameter date: a date to convert into a string
	/// - Returns: a human readable string from the given date.
	func string(from date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd MMM YYYY"
		return formatter.string(from: date)
	}
	
	func authorString(for post: Flickr.Post) -> String {
		post.author == nil ? NSLocalizedString("Author Unknown", comment: "") : NSLocalizedString("Author:\n\(post.author!)", comment: "")
	}
	
	func titleString(for post: Flickr.Post) -> String {
		post.title ?? ""
	}
	
	func tagString(for post: Flickr.Post) -> String {
		post.tags.isEmpty ? NSLocalizedString("None", comment: "") : post.tags
	}

	/// Returns a correct URL for an image that should be displayed in the grid view.
	/// - Parameter post: a Flickr post instance to search the URL for
	func gridImageURL(for post: Flickr.Post) -> URL {
		post.media[.squaredLarge]!
	}
	
	/// Returns a correct URL for an image that should be displayed in the post details view.
	/// - Parameter post: a Flickr post instance to search the URL for
	func postImageURL(for post: Flickr.Post) -> URL {
		post.media[.large]!
	}
	
	static var defaultPostPreviewSize: CGSize {
		Flickr.Post.defaultPreviewSize
	}
}
