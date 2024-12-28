//
//  HapticManager.swift
//  shapelogic
//
//  Created by arishal on 12/28/24.
//

import Foundation
import UIKit

// Singleton manager for consistent haptic feedback across the app
final class HapticManager {
    static let shared = HapticManager()
    
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for lower latency
        selectionFeedback.prepare()
        impactFeedback.prepare()
        notificationFeedback.prepare()
    }
    
    // Card selection feedback
    func cardSelected() {
        selectionFeedback.selectionChanged()
    }
    
    // Valid set found
    func validSetFound() {
        notificationFeedback.notificationOccurred(.success)
    }
    
    // Invalid set attempted
    func invalidSetAttempted() {
        notificationFeedback.notificationOccurred(.error)
    }
    
    // Perfect set found (Set-243 specific)
    func perfectSetFound() {
        // Double tap pattern
        Task { @MainActor in
            impactFeedback.impactOccurred(intensity: 1.0)
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            impactFeedback.impactOccurred(intensity: 0.7)
        }
    }
}
