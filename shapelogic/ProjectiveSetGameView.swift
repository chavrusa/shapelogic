//
//  ProjectiveSetGameView.swift
//  shapelogic
//
//  Created by arishal on 11/26/24.
//

import Foundation
import SwiftUI

struct ProjectiveSetGameView: View {
    @StateObject private var game = ProjectiveSetGame()
    @State private var showingWinAlert = false
    @Binding var navigationPath: NavigationPath
    
    private let dotColors: [Color] = [
        Color(hex: "#fd05a1"),
        Color(hex: "#ff8200"),
        Color(hex: "#ffdd47"),
        Color(hex: "#3fae2a"),
        Color(hex: "#2c7ce5"),
        Color(hex: "#7209b7")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Score header - Always at top of screen
            VStack {
                Text("Score: \(game.score)")
                    .font(.title2.bold())
                    .adaptiveHeader()
                
                if !game.drawPile.isEmpty {
                    Text("\(game.drawPile.count) cards remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Cards section - has been adapted to ipad
            GeometryReader { geometry in
                let spacing: CGFloat = DeviceAdaptation.isIPad ? 24 : 12
                let availableWidth = min(geometry.size.width - (spacing * 4),
                                      DeviceAdaptation.GameVariant.projective.containerWidth)
                let cardWidth = availableWidth / 3
                let cardHeight = cardWidth * 1.4
                
                VStack {
                    Spacer()
                    
                    // Only the card layout gets the device adaptation
                    VStack(spacing: spacing) {
                        // Top pair
                        CardRow(cards: Array(game.tableCards.prefix(2)),
                               cardWidth: cardWidth,
                               cardHeight: cardHeight,
                               spacing: spacing,
                               colors: dotColors,
                               selectedCards: game.selectedCards,
                               onSelect: game.selectCard)
                        
                        // Middle trio
                        CardRow(cards: Array(game.tableCards.dropFirst(2).prefix(3)),
                               cardWidth: cardWidth,
                               cardHeight: cardHeight,
                               spacing: spacing,
                               colors: dotColors,
                               selectedCards: game.selectedCards,
                               onSelect: game.selectCard)
                        
                        // Bottom pair
                        CardRow(cards: Array(game.tableCards.dropFirst(5)),
                               cardWidth: cardWidth,
                               cardHeight: cardHeight,
                               spacing: spacing,
                               colors: dotColors,
                               selectedCards: game.selectedCards,
                               onSelect: game.selectCard)
                    }
                    .adaptToDevice(.projective) // Only adapt the card layout
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer() // Push the button to bottom
            
            // Button - Always at bottom of screen
            Button("New Game") {
                withAnimation {
                    game.startNewGame()
                }
            }
            .buttonStyle(.borderedProminent)
            .font(DeviceAdaptation.buttonFont)
            .padding(.bottom)
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

struct CardRow: View {
    let cards: [ProjectiveCard]
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let spacing: CGFloat
    let colors: [Color]
    let selectedCards: Set<ProjectiveCard>
    let onSelect: (ProjectiveCard) -> Void
    
    var body: some View {
        HStack(spacing: spacing) {
            if cards.count < 3 { Spacer() }
            ForEach(cards) { card in
                ProjectiveCardView(card: card,
                                isSelected: selectedCards.contains(card),
                                colors: colors)
                    .frame(width: max(cardWidth, 0), height: max(cardHeight, 0))
                    .onTapGesture {
                        withAnimation {
                            onSelect(card)
                        }
                    }
            }
            if cards.count < 3 { Spacer() }
        }
    }
}

struct ProjectiveCardView: View {
    let card: ProjectiveCard
    let isSelected: Bool
    let colors: [Color]
    @Environment(\.colorScheme) private var colorScheme 
    
    var body: some View {
        GeometryReader { geometry in
            let dotSize = min(geometry.size.width / 3.5, geometry.size.height / 6)
            let dotSpacing = dotSize * 0.7
            
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: DeviceAdaptation.isIPad ? 40 : 20)
                    .fill(colorScheme == .dark ? .black : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: DeviceAdaptation.isIPad ? 40 : 20)
                            .strokeBorder(isSelected ? .blue : .gray,
                                        lineWidth: isSelected ? 3 : 1)
                    )
                
                // 2x3 grid of dots
                VStack(spacing: dotSpacing) {
                    // Top row
                    HStack(spacing: dotSpacing) {
                        DotView(color: colors[0], exists: card.hasFeature(0), size: dotSize)
                        DotView(color: colors[1], exists: card.hasFeature(1), size: dotSize)
                    }
                    // Middle row
                    HStack(spacing: dotSpacing) {
                        DotView(color: colors[2], exists: card.hasFeature(2), size: dotSize)
                        DotView(color: colors[3], exists: card.hasFeature(3), size: dotSize)
                    }
                    // Bottom row
                    HStack(spacing: dotSpacing) {
                        DotView(color: colors[4], exists: card.hasFeature(4), size: dotSize)
                        DotView(color: colors[5], exists: card.hasFeature(5), size: dotSize)
                    }
                }
                .padding(dotSize * 0.5) // Keep consistent padding around grid
            }
        }
    }
}

struct DotView: View {
    let color: Color
    let exists: Bool
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(color.opacity(exists ? 1 : 0))
            .frame(width: size, height: size)
    }
}

#Preview {
    NavigationStack {
        ProjectiveSetGameView(navigationPath: .constant(NavigationPath()))
    }
}
