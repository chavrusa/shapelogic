//
//  shapelogicApp.swift
//  shapelogic
//
//  Created by arishal on 12/8/24.
//

import SwiftUI

@main
struct ShapeLogicApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            NavigationWrapper()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        DeviceAdaptation.isIPad ? .all : .portrait
    }
}
