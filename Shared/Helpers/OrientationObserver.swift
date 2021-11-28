//
//  OrientationObserver.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import Combine
import UIKit

final class OrientationObserver: ObservableObject {
	enum Orientation {
		case portrait
		case landscape
		
		/// Creates an instance that represents currnt UIDevice orientation
		init() {
			if UIDevice.current.orientation.isLandscape {
				self = .landscape
			}
			else {
				self = .portrait
			}
		}
	}
	
	@Published var orientation: Orientation = .init()
	private var subscriber: AnyCancellable?
	
	init() {
		// listen to the notification...
		// unowned self so it'll unregister before self becomes invalid
		subscriber = NotificationCenter.default
			.publisher(for: UIDevice.orientationDidChangeNotification)
			.sink(receiveValue: { [unowned self] notification in
				guard let device = notification.object as? UIDevice else {
					return
				}
				if device.orientation.isPortrait {
					self.orientation = .portrait
				}
				else if device.orientation.isLandscape {
					self.orientation = .landscape
				}
			})
	}
				  
	deinit {
		subscriber?.cancel()
		subscriber = nil
	}
}
