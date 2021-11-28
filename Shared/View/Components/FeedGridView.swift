//
//  FeedGridView.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import SwiftUI

struct FeedGridView: View {
	@EnvironmentObject private var feedStore: ViewModel
	@Binding var scaleFactor: ScaleFactor
	@StateObject var observer = OrientationObserver()
	private let spacing: CGFloat = 2
	
	/// Layout the feed items according to the device and its orientation
	var gridItemLayout: [GridItem] {
		var item = GridItem(.flexible())
		item.spacing = spacing
		
		switch scaleFactor {
		case .small:
			if UIDevice.isIPad {
				if observer.orientation == .landscape {
					return .init(repeating: item, count: 12)
				} else {
					return .init(repeating: item, count: 6)
				}
			} else {
				if observer.orientation == .landscape {
					return .init(repeating: item, count: 6)
				} else {
					return .init(repeating: item, count: 4)
				}
			}
		case .normal:
			if UIDevice.isIPad {
				if observer.orientation == .landscape {
					return .init(repeating: item, count: 10)
				} else {
					return .init(repeating: item, count: 5)
				}
			} else {
				if observer.orientation == .landscape {
					return .init(repeating: item, count: 5)
				} else {
					return .init(repeating: item, count: 3)
				}
			}
		case .large:
			if UIDevice.isIPad {
				if observer.orientation == .landscape {
					return .init(repeating: item, count: 8)
				} else {
					return .init(repeating: item, count: 4)
				}
			} else {
				if observer.orientation == .landscape {
					return .init(repeating: item, count: 4)
				} else {
					return .init(repeating: item, count: 2)
				}
			}
		}
	}
	
	var body: some View {
		LazyVGrid(columns: gridItemLayout, spacing: spacing) {
			ForEach(feedStore.posts) { post in
				RemoteImage(url: feedStore.gridImageURL(for: post)) { image in
					NavigationLink {
						PostView(post: post)
					} label: {
						image .resizable()
					}
				} placeholder: {
					GridImagePlaceholder()
				}
				.aspectRatio(1, contentMode: .fit)
			}
		}
	}
}

struct FeedGridView_Previews: PreviewProvider {
    static var previews: some View {
		FeedGridView(scaleFactor: .constant(.normal))
    }
}
