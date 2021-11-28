//
//  GridImagePlaceholder.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import SwiftUI

struct GridImagePlaceholder: View {
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 13)
				.stroke(Color.blue, lineWidth: 0.5)
				.opacity(0)
			
			ProgressView.init()
				.progressViewStyle(CircularProgressViewStyle(tint: .blue))
				.controlSize(.large)
		}
	}
}

struct GridImagePlaceholder_Previews: PreviewProvider {
    static var previews: some View {
		GridImagePlaceholder()
    }
}
