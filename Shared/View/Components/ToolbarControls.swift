//
//  ToolbarControls.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 28.11.2021.
//

import SwiftUI

struct ToolbarControls: View {
	@EnvironmentObject private var feedStore: ViewModel
	@Binding var scaleFactor: ScaleFactor

	var body: some View {
		HStack {
			Button {
				withAnimation {
					scaleFactor = scaleFactor.previous
				}
			} label: {
				Image(systemName: "minus.magnifyingglass")
			}
			.disabled(scaleFactor == .small)

			Button {
				withAnimation {
					scaleFactor = scaleFactor.next
				}
			} label: {
				Image(systemName: "plus.magnifyingglass")
			}
			.disabled(scaleFactor == .large)
		}
		.disabled(feedStore.posts.isEmpty)
	}
}

struct ToolbarControls_Previews: PreviewProvider {
    static var previews: some View {
		ToolbarControls(scaleFactor: .constant(.normal))
			.environmentObject(ViewModel.shared)
    }
}
