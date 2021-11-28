//
//  NoContentView.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import SwiftUI

/// A view that displays an appropriate message when there's no content to show.
struct NoContentView: View {
    var body: some View {
		VStack {
			Image(systemName: "rectangle.on.rectangle.slash.circle")
				.resizable()
				.font(Font.system(size: 200, weight: .ultraLight))
				.frame(width: 200, height: 200)
				.opacity(0.8)
			Text("No posts were found")
				.font(.callout)
		}
		.foregroundColor(.secondary)
		.foregroundStyle(.ultraThinMaterial)
    }
}

struct NoContentView_Previews: PreviewProvider {
    static var previews: some View {
        NoContentView()
    }
}
