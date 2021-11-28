//
//  RemoteImage.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import SwiftUI

/// Remote image allows the ability to load an image from a URL while presentting a placeholder view, untril the downloading process is finished.
///
/// By using NetworkManager helper class, RemoteImage caching all its data with URLSession
struct RemoteImage<Placeholder: View, ConfiguredImage: View>: View {
	private let placeholder: () -> Placeholder
	private let content: (Image) -> ConfiguredImage

	@ObservedObject private var remoteImageService: RemoteImageService
	@State private var loadedImage: UIImage?

	init( url: URL?,
		  @ViewBuilder _ content: @escaping (Image) -> ConfiguredImage,
		  @ViewBuilder placeholder: @escaping () -> Placeholder) {
		self.placeholder = placeholder
		self.content = content
		self.remoteImageService = RemoteImageService(url: url)
	}
	
	@ViewBuilder private var imageContent: some View {
		if let data = loadedImage {
			content(Image(uiImage: data))
		} else {
			placeholder()
		}
	}

	var body: some View {
		imageContent
			.onReceive(remoteImageService.$image) { imageData in
				self.loadedImage = imageData
			}
	}
}

private class RemoteImageService: ObservableObject {
	@Published var image: UIImage?

	convenience init(url: URL?) {
		self.init()
		
		if let url = url {
			loadImage(for: url)
		}
	}

	func loadImage(for url: URL) {
		// use the network manager service because it does all the caching
		NetworkManager.shared.retrieveData(from: url) { data, _ in
			guard let data = data, let image = UIImage(data: data) else { return }
			DispatchQueue.main.async {
				self.image = image
			}
		}
	}
}
