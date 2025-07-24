//
//  PresageSDKSampleApp.swift
//  PresageSDKSample
//
//  Created by Reuben Varghese on 7/17/25.
//

import SwiftUI

@main
struct PresageSDKSampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HeadlessSDKExample()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
