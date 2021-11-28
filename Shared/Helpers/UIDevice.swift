//
//  UIDevice.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import UIKit

extension UIDevice {
	static var isIPad: Bool {
		UIDevice.current.userInterfaceIdiom == .pad
	}
	
	static var isIPhone: Bool {
		UIDevice.current.userInterfaceIdiom == .phone
	}
}
