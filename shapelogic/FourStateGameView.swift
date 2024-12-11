//
//  FourStateGameView.swift
//  shapelogic
//
//  Created by arishal on 12/10/24.
//

import Foundation
import SwiftUI

/*
// Custom shapes for the game
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Make it equilateral
        let height = rect.width * sqrt(3) / 2
        let centerY = rect.midY
        path.move(to: CGPoint(x: rect.midX, y: centerY - height/2))
        path.addLine(to: CGPoint(x: rect.maxX, y: centerY + height/2))
        path.addLine(to: CGPoint(x: rect.minX, y: centerY + height/2))
        path.closeSubpath()
        return path
    }
}

struct RoundedSquare: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) * 0.2 // Corner radius
        let rect = rect.insetBy(dx: rect.width * 0.06, dy: rect.height * 0.06) // Make slightly smaller like other shapes
        return Path(roundedRect: rect, cornerRadius: radius)
    }
}

struct Rhombus: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width * 1.1
        let height = rect.height * 1.1
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - height/2))  // top
        path.addLine(to: CGPoint(x: center.x + width/2, y: center.y))  // right
        path.addLine(to: CGPoint(x: center.x, y: center.y + height/2))  // bottom
        path.addLine(to: CGPoint(x: center.x - width/2, y: center.y))  // left
        path.closeSubpath()
        return path
    }
}
 */

struct StripedCircle: View {
    let color: Color
    
    var body: some View {
        Circle()
            .stroke(color, lineWidth: 2)
            .overlay(
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let stripeCount = 6  // Number of stripes
                    let stripeSpacing = size / CGFloat(stripeCount)
                    
                    Path { path in
                        for i in 0...stripeCount {
                            let y = CGFloat(i) * stripeSpacing
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size, y: y))
                        }
                    }
                    .stroke(color, lineWidth: 1)
                    .clipShape(Circle().inset(by: 1)) // Inset to avoid edge artifacts
                }
            )
    }
}

struct VerticalLineCircle: View {
    let color: Color
    
    var body: some View {
        Circle()
            .stroke(color, lineWidth: 2)
            .overlay(
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    Path { path in
                        path.move(to: CGPoint(x: size/2, y: 0))  // Start just inside the circle
                        path.addLine(to: CGPoint(x: size/2, y: size))  // End just inside the circle
                    }
                    .stroke(color, lineWidth: 2)
                }
            )
    }
}

struct FourStateSetGameView: View {
    @StateObject private var game = FourStateGame()
    @State private var showingWinAlert = false
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Score: \(game.score)")
                .font(.title2.bold())
                .adaptiveHeader()
            
            if !game.drawPile.isEmpty {
                Text("\(game.drawPile.count) cards remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                let spacing: CGFloat = 8
                let availableWidth = min(geometry.size.width - spacing * 5, 800)
                let cardWidth = (availableWidth - spacing * 3) / 4
                
                let columns = Array(repeating: GridItem(.fixed(cardWidth), spacing: spacing), count: 4)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(game.onTable) { card in
                            FourStateCardView(
                                card: card,
                                isSelected: game.selectedCards.contains(card)
                            )
                            .aspectRatio(1.0, contentMode: .fit)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    game.selectCard(card)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, spacing)
                }
            }
            
            HStack(spacing: 20) {
                Button("New Game") {
                    withAnimation {
                        game.startNewGame()
                    }
                }
                .buttonStyle(.borderedProminent)
                .font(DeviceAdaptation.buttonFont)
                
                if !game.drawPile.isEmpty {
                    Button("Deal More") {
                        withAnimation {
                            game.deal()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .font(DeviceAdaptation.buttonFont)
                }
            }
            .padding()
        }
        .alert("Congratulations!", isPresented: $showingWinAlert) {
            Button("New Game") {
                game.startNewGame()
            }
            Button("Return to Menu") {
                navigationPath = NavigationPath()
            }
        } message: {
            Text("You've found all the sets!")
        }
        .onChange(of: game.isGameOver) { _, isOver in
            if isOver {
                showingWinAlert = true
            }
        }
    }
}

struct FourStateCardView: View {
    let card: FourStateCard
    let isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private let colors: [Color] = [.red, .cyan, .purple, .green]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? .black : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? .blue : .gray,
                                        lineWidth: isSelected ? 3 : 1)
                    )
                
                // Shape container
                let containerSize = min(geometry.size.width, geometry.size.height) * 0.85
                let shapeSize = containerSize * 0.3
                
                Group {
                    switch card.number {
                    case 0: // Single shape in center
                        circleVariant
                            .frame(width: shapeSize, height: shapeSize)
                    case 1: // Two shapes side by side
                        HStack(spacing: containerSize * 0.12) {
                            ForEach(0..<2) { _ in
                                circleVariant
                                    .frame(width: shapeSize, height: shapeSize)
                            }
                        }
                    case 2: // Three shapes in diagonal
                        /* ZStack {
                            ForEach(0..<3) { index in
                                circleVariant
                                    .frame(width: shapeSize, height: shapeSize)
                                    .offset(
                                        x: CGFloat(index - 1) * containerSize * 0.35,
                                        y: CGFloat(index - 1) * containerSize * 0.35
                                    )
                            }
                        } */
                        // Three shapes in a triangle
                        VStack(spacing: shapeSize * 0.125) {
                            circleVariant
                                .frame(width: shapeSize, height: shapeSize)
                            HStack(spacing: shapeSize * 0.3) {
                                ForEach(0..<2) { _ in
                                    circleVariant
                                        .frame(width: shapeSize, height: shapeSize)
                                }
                            }
                         }

                    case 3: // Four shapes in square
                        VStack(spacing: containerSize * 0.1) {
                            HStack(spacing: containerSize * 0.1) {
                                ForEach(0..<2) { _ in
                                    circleVariant
                                        .frame(width: shapeSize, height: shapeSize)
                                }
                            }
                            HStack(spacing: containerSize * 0.1) {
                                ForEach(0..<2) { _ in
                                    circleVariant
                                        .frame(width: shapeSize, height: shapeSize)
                                }
                            }
                        }
                    default:
                        EmptyView()
                    }
                }
                .frame(width: containerSize, height: containerSize)
            }
        }
    }
    
    @ViewBuilder
    private var circleVariant: some View {
        let color = colors[card.color]
        
        switch card.shape {
        case 0:  // Filled circle
            Circle()
                .fill(color)
        case 1:  // Outlined circle
            Circle()
                .stroke(color, lineWidth: 2)
        case 2:  // Striped circle
            StripedCircle(color: color)
        default:  // Semi-transparent filled circle
            VerticalLineCircle(color: color)
            /*Circle()
                .fill(color.opacity(0.5))
                .stroke(color, lineWidth: 2)*/
        }
    }
}

#Preview {
    NavigationStack {
        FourStateSetGameView(navigationPath: .constant(NavigationPath()))
    }
}
