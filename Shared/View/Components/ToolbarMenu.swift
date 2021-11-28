//
//  ToolbarMenu.swift
//  FlickrPublicFeed
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import SwiftUI

struct ToolbarMenu: View {
	@EnvironmentObject private var feedStore: ViewModel

	var body: some View {
		Menu {
			// a picker to switch between sorting orders with animation of state changes
			Picker(selection: $feedStore.sortOrder.animation(), label: Text(""), content: {
				ForEach(SortOrder.allCases, id: \.self) {
					Text("By " + $0.localizedTitle).tag($0.rawValue)
				}
			})
		} label: {
			Text("Sort Order")
		}
		.disabled(feedStore.posts.isEmpty)
	}
}

struct ToolbarMenu_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarMenu()
			.environmentObject(ViewModel.shared)
    }
}
