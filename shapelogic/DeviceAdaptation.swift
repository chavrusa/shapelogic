//
//  DeviceAdaptation.swift
//  shapelogic
//
//  Created by arishal on 11/28/24.
//

import Foundation
import SwiftUI

enum DeviceAdaptation {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Reusable style values
    static var buttonFont: Font {
        isIPad ? .title3.bold() : .body
    }
    
    // Game-specific adaptations
    enum GameVariant {
        case classic
        case set243
        case projective
        case fourstate
        
        var cardScale: CGFloat {
            switch self {
            case .classic:
                return DeviceAdaptation.isIPad ? 0.85 : 1.0
            case .set243:
                return DeviceAdaptation.isIPad ? 0.7 : 1.0
            case .projective:
                return DeviceAdaptation.isIPad ? 0.6 : 1.0
            case .fourstate:
                return DeviceAdaptation.isIPad ? 0.6 : 1.0
            }
        }
        
        // New: Shape scaling relative to card size
        var shapeScale: CGFloat {
            switch self {
            case .classic, .set243:
                return DeviceAdaptation.isIPad ? 1.4 : 1.0  // Bigger shapes on iPad
            case .projective:
                return DeviceAdaptation.isIPad ? 1.2 : 1.0  // Moderate increase for dots
            case .fourstate:
                return 1.0
            }
        }
        
        // Card layout container width
        var containerWidth: CGFloat {
            switch self {
            case .classic:
                return 800
            case .set243:
                return 800
            case .projective:
                return 700
            case .fourstate:
                return 600
            }
        }
    }
    
    struct HeaderBackground: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(uiColor: .systemGray6))
        }
    }
    
    struct AdaptiveContainer: ViewModifier {
        let variant: GameVariant
        
        func body(content: Content) -> some View {
            if DeviceAdaptation.isIPad {
                GeometryReader { geometry in
                    HStack {
                        Spacer(minLength: 0)
                        VStack(spacing: 0) {
                            content
                                .frame(maxWidth: variant.containerWidth)
                                .scaleEffect(variant.cardScale)
                            Spacer(minLength: 0)
                        }
                        .frame(maxHeight: geometry.size.height)
                        Spacer(minLength: 0)
                    }
                }
            } else {
                content
            }
        }
    }
}

extension View {
    func adaptToDevice(_ variant: DeviceAdaptation.GameVariant) -> some View {
        modifier(DeviceAdaptation.AdaptiveContainer(variant: variant))
    }
    
    func adaptiveHeader() -> some View {
        modifier(DeviceAdaptation.HeaderBackground())
    }
}
