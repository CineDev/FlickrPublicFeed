//
//  App.swift
//  Shared
//
//  Created by Vitaliy Vashchenko on 27.11.2021.
//

import SwiftUI

@main
struct FlickrPublicFeedApp: App {
	@StateObject private var viewModel = ViewModel.shared
	@State private var shouldShowDisconnectionAlert = false

    var body: some Scene {
        WindowGroup {
            ContentView()
				.environmentObject(viewModel)
				.onReceive(viewModel.$networkStatus, perform: { value in
					// this won't work on simulator, please use a real iPhone
					if value == .disconnected {
						shouldShowDisconnectionAlert = true
					} else {
						viewModel.refresh()
					}
				})
				.alert(isPresented: $shouldShowDisconnectionAlert, error: NetworkError.noConnection, actions: { _ in
					Text("OK")
				}, message: { error in
					Text(error.failureReason ?? "")
				})
        }
    }
}
