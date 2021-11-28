//
//  PostSortable.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import Foundation

// MARK: - PostSortable Protocol

protocol PostSortable {
	
}

extension PostSortable {
	/// Sorts given Flickr posts by a specified sort order.
	/// - Returns: a sorted array of Flickr posts.
	static func sort(_ posts: [Flickr.Post], by order: SortOrder) -> [Flickr.Post] {
		switch order {
		case .publishingDate:
			return posts.sorted(by: { $0.publishedDate < $1.publishedDate })
		case .creationData:
			return posts.sorted(by: { $0.takenDate < $1.takenDate })
		}
	}
}


// MARK: Sort Order

enum SortOrder: Int, CaseIterable {
	case publishingDate
	case creationData
}

extension SortOrder {
	var localizedTitle: String {
		switch self {
		case .publishingDate:
			return NSLocalizedString("Publication Date", comment: "")
		case .creationData:
			return NSLocalizedString("Creation Date", comment: "")
		}
	}
}
