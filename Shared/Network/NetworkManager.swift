//
//  NetworkManager.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import Foundation
import Network
import OSLog

/// The main helper class for any network actions required by the ViewModel and views.
///
/// Uses URLSession for caching purposes.
class NetworkManager: ObservableObject {
	// MARK: - Properties
	
	@Published var error: NetworkError?
	@Published var status: NetworkStatus = .init()

	// monitor that controls the network status updates
	private let monitor = NWPathMonitor()
	
	// a queue for the monitor to work on
	private let queue = DispatchQueue(label: "NetworkManager")
	
	// The singleton
	static let shared = NetworkManager()

	
	// MARK: - Caching
	
	/// Custom URLSession that uses the cache
	lazy var session: URLSession = {
		let config = URLSessionConfiguration.default
		config.urlCache = .shared
		return URLSession(configuration: config)
	}()

	
	// MARK: - Constructor/Desctructor
	
	private init() {
		// start the network monitor
		// IMPORTANT: this won't work on simulator, please use a real iPhone
		monitor.pathUpdateHandler = { path in
			DispatchQueue.main.async { [weak self] in
				self?.status = NetworkStatus.from(path.status)
			}
		}
		monitor.start(queue: queue)
	}
	
	deinit {
		// cancel the monitor
		monitor.cancel()
	}
	
	
	// MARK: - Retreiving And Caching Data
	
	/// Loads a data from the given URL.
	/// - Parameters:
	///   - url: url to retrieve a data from
	///   - completionHandler: The completion handler block that’s invoked after the request has finished processing.
	func retrieveData(from remoteURL: URL, _ completionHandler: @escaping (Data?, NetworkError?)->()) {
		let request = URLRequest(url: remoteURL)
		
		// otherwise, download data from the remote URL and cache it if it's an image
		session.downloadTask(with: request) { [unowned self] url, response, error in
			// if there's a cached data for the remoteURL, return that data from cache (or don't if it's not an image, so the feed would reload)
			if let cachedData = URLCache.shared.cachedResponse(for: request)?.data {
				if self.status == .disconnected && !cachedData.isImageData || cachedData.isImageData {
					completionHandler(cachedData, nil)
					return
				}
			}

			guard let response = response, let url = url,
				  let data = try? Data(contentsOf: url, options: [.mappedIfSafe])
			else {
				completionHandler(nil, .noConnection)
				return
			}
			
			// store data in cache if that's an image
			self.session.configuration.urlCache?.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
			
			// call the completion handler when the data is downloaded and cached
			completionHandler(data, nil)
		}
		.resume()
	}
	
	/// Return cached data for a given URL if any.
	func cachedData(from url: URL) -> Data? {
		let request = URLRequest(url: url)
		return URLCache.shared.cachedResponse(for: request)?.data
	}
	
	/// Returns *true* if a given URL is already cached.
	func isCached(_ url: URL) -> Bool {
		cachedData(from: url) != nil
	}
}
