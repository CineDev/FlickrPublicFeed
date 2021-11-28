//
//  NetworkStatus.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import Network

enum NetworkStatus: Equatable {
	case connected
	case disconnected
	
	init() {
		self = .connected
	}
	
	static func from(_ pathStatus: NWPath.Status) -> Self {
		if pathStatus == .satisfied {
			return .connected
		}
		return .disconnected
	}
}
