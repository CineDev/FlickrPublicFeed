//
//  NetworkError.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import Foundation

enum NetworkError: Int, LocalizedError, Identifiable {
	case noConnection
	case invalidResponse
	
	var id: Int {
		self.rawValue
	}
	
	var errorDescription: String? {
		switch self {
		case .noConnection:
			return NSLocalizedString("Server Not Available", comment: "")
		case .invalidResponse:
			return NSLocalizedString("Invalid Response", comment: "")
		}
	}
	var failureReason: String? {
		switch self {
		case .noConnection:
			return NSLocalizedString("Please check you Interner connection.", comment: "")
		case .invalidResponse:
			return NSLocalizedString("Server returned data in an unsupported format.", comment: "")
		}
	}
}
