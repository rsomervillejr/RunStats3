//
//  RunStats3App.swift
//  RunStats3
//
//  Created by Ronald Somerville on 5/25/26.
//

import SwiftUI
import SwiftData

@main
struct RunStats3App: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
        .modelContainer(for: [Run.self, Split.self])
    }
}
