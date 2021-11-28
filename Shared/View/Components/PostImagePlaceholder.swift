//
//  PostImagePlaceholder.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import SwiftUI

struct PostImagePlaceholder: View {
    var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 13)
				.stroke(Color.blue, lineWidth: 0.5)
				.opacity(0)
			
			ProgressView.init()
				.progressViewStyle(CircularProgressViewStyle(tint: .blue))
				.controlSize(.large)
		}
		.frame(height: ViewModel.defaultPostPreviewSize.height)
    }
}

struct PostImagePlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        PostImagePlaceholder()
    }
}
