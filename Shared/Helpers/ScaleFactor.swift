//
//  ScaleFactor.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import Foundation

enum ScaleFactor: Int {
	case small
	case normal
	case large
	
	var previous: Self {
		switch self {
		case .small: return .small
		case .normal: return .small
		case .large: return .normal
		}
	}

	var next: Self {
		switch self {
		case .small: return .normal
		case .normal: return .large
		case .large: return .large
		}
	}
}
