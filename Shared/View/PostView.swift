//
//  PostView.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import SwiftUI

struct PostView: View {
	@EnvironmentObject private var viewModel: ViewModel
	@State private var isVisitingServer: Bool = false
	let post: Flickr.Post
	
	var body: some View {
		Form {
			Section {
				RemoteImage(url: viewModel.postImageURL(for: post)) { image in
					image
						.resizable()
						.scaledToFit()
				} placeholder: {
					PostImagePlaceholder()
				}
			} header: {
				Text(viewModel.authorString(for: post))
			} footer: {
				Text(viewModel.titleString(for: post))
			}
			
			Section {
				HStack {
					Text("Creation Date")
						.font(.callout)
						.foregroundColor(.secondary)
					Spacer()
					Text(viewModel.string(from: post.takenDate))
						.font(.callout)
				}
				HStack {
					Text("Published Date")
						.font(.callout)
						.foregroundColor(.secondary)
					Spacer()
					Text(viewModel.string(from: post.publishedDate))
						.font(.callout)
				}
			}
			
			Section {
				VStack(alignment: .leading) {
					Text("Tags")
						.font(.callout)
						.foregroundColor(.secondary)
					Spacer()
					Text(viewModel.tagString(for: post))
						.lineLimit(3)
				}
			}
			
			HStack {
				Spacer()
				Button {
					isVisitingServer.toggle()
				} label: {
					Text("See on Flickr")
				}
				Spacer()
			}
		}
		.navigationBarTitleDisplayMode(.inline)
		.sheet(isPresented: $isVisitingServer) {
			SafariView(url: post.link)
		}
	}
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
		PostView(post: Flickr.Post.testable)
			.environmentObject(ViewModel.shared)
    }
}
