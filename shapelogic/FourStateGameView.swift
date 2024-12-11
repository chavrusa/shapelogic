//
//  FourStateGameView.swift
//  shapelogic
//
//  Created by arishal on 12/10/24.
//

import Foundation
import SwiftUI

// Custom shapes for the game
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Pentagon: Shape {
    func path(in rect: CGRect) -> Path {
        let path = Path { p in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let angle = 2 * 3.1415 / 5
            
            for i in 0..<5 {
                let x = center.x + radius * cos(angle * Double(i) - .pi / 2)
                let y = center.y + radius * sin(angle * Double(i) - .pi / 2)
                if i == 0 {
                    p.move(to: CGPoint(x: x, y: y))
                } else {
                    p.addLine(to: CGPoint(x: x, y: y))
                }
            }
            p.closeSubpath()
        }
        return path
    }
}

struct FourStateSetGameView: View {
    @StateObject private var game = FourStateGame()
    @State private var showingWinAlert = false
    @Binding var navigationPath: NavigationPath
    
    private let colors: [Color] = [.red, .cyan, .purple, .green]
    
    var body: some View {
        VStack(spacing: 16) {
            // Score header
            Text("Score: \(game.score)")
                .font(.title2.bold())
                .adaptiveHeader()
            
            if !game.drawPile.isEmpty {
                Text("\(game.drawPile.count) cards remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Card grid
            GeometryReader { geometry in
                let spacing: CGFloat = 12
                let availableWidth = min(geometry.size.width - spacing * 4, 800)
                let cardWidth = (availableWidth - spacing * 2) / 3
                
                let columns = [
                    GridItem(.fixed(cardWidth)),
                    GridItem(.fixed(cardWidth)),
                    GridItem(.fixed(cardWidth))
                ]
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: spacing) {
                        ForEach(game.onTable) { card in
                            FourStateCardView(
                                card: card,
                                isSelected: game.selectedCards.contains(card)
                            )
                            .aspectRatio(1.6, contentMode: .fit)
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
            
            // Game controls
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
                
                // Shapes
                let shapeWidth = min(geometry.size.width * 0.2, 50)
                let shapeHeight = shapeWidth * 1.6
                
                let positions = calculateShapePositions(
                    count: card.number + 1,
                    containerWidth: geometry.size.width,
                    shapeWidth: shapeWidth
                )
                
                ForEach(0..<card.number + 1, id: \.self) { index in
                    cardShape
                        .frame(width: shapeWidth, height: shapeHeight)
                        .position(x: positions[index].x, y: geometry.size.height / 2)
                }
            }
        }
    }
    
    private func calculateShapePositions(count: Int, containerWidth: CGFloat, shapeWidth: CGFloat) -> [CGPoint] {
        let spacing = shapeWidth * 0.3
        let totalWidth = CGFloat(count) * shapeWidth + CGFloat(count - 1) * spacing
        let startX = (containerWidth - totalWidth) / 2 + shapeWidth / 2
        
        return (0..<count).map { index in
            CGPoint(x: startX + CGFloat(index) * (shapeWidth + spacing), y: 0)
        }
    }
    
    @ViewBuilder
    private var cardShape: some View {
        let shape = switch card.shape {
        case 0: AnyShape(Circle())
        case 1: AnyShape(Triangle())
        case 2: AnyShape(Rectangle())
        default: AnyShape(Pentagon())
        }
        
        shape.fill(colors[card.color])
    }
}

#Preview {
    NavigationStack {
        FourStateSetGameView(navigationPath: .constant(NavigationPath()))
    }
}
