//
//  SafariView.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import SwiftUI
import SafariServices

/// Helper view that displays the standard Safari interface and remote content.
struct SafariView: UIViewControllerRepresentable {

	let url: URL

	func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
		return SFSafariViewController(url: url)
	}

	func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

	}
}
