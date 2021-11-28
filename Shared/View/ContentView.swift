//
//  ContentView.swift
//  Shared
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import SwiftUI
import Combine

struct ContentView: View {
	@EnvironmentObject private var viewModel: ViewModel
	@AppStorage("scaleFactor") private var scaleFactor: ScaleFactor = .small
	
	fileprivate var isShowingError: Binding<Bool> {
		Binding<Bool> {
			viewModel.error != nil
		} set: { newValue, _ in
			if !newValue {
				viewModel.error = nil
			}
		}
	}
			
	var body: some View {
		NavigationView {
			ZStack {
				// when there's no posts to show, display the corresponding view
				if viewModel.posts.isEmpty && !viewModel.tags.isEmpty {
					NoContentView()
				} else {
					ScrollView {
						// otherwise display the grid view showing every Flickr post
						FeedGridView(scaleFactor: $scaleFactor)
						
						if viewModel.posts.count > 0 && viewModel.networkStatus == .disconnected {
							Text("The cached feed is being shown")
								.font(.caption)
								.foregroundColor(.secondary)
								.padding(.vertical)
						}
					}
				}
			}
			.navigationTitle("Flickr Public Feed")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					ToolbarControls(scaleFactor: $scaleFactor)
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					ToolbarMenu()
				}
			}
		}
		.navigationViewStyle(.stack)
		
		.onChange(of: viewModel.tags) { newValue in
			// simulate a debounce function in reactive programming,
			// so the search results won't draw as fast as the user types the text
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
				if self.viewModel.tags == newValue {
					viewModel.refresh()
				}
			}
		}
		
		.alert(isPresented: isShowingError, error: viewModel.error as? NetworkError, actions: { _ in
			Text("OK")
		}, message: { error in
			Text(error.failureReason ?? "")
		})

		.searchable(text: $viewModel.tags, prompt: "Filter by tags")
    }
}

struct ContentView_Previews: PreviewProvider {
	@State static private var viewModel = ViewModel.shared

	static var previews: some View {
		viewModel.refresh()
		
		return ContentView()
			.environmentObject(viewModel)
			.environmentObject(NetworkManager.shared)
	}
}
