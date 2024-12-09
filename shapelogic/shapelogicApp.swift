//
//  shapelogicApp.swift
//  shapelogic
//
//  Created by arishal on 12/8/24.
//

import SwiftUI

@main
struct setApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
        
    var body: some Scene {
        WindowGroup {
            NavigationWrapper()
                .preferredColorScheme(.none) // Allow system color scheme
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        DeviceAdaptation.isIPad ? .all : .portrait
    }
}
