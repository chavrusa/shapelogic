//
//  Set243GameView.swift
//  set
//
//  Created by arishal on 11/27/24.
//

import Foundation
import SwiftUI

struct Set243GameView: View {
    @StateObject private var game = Set243Game()
    @State private var showingWinAlert = false
    @Binding var navigationPath: NavigationPath
    @Namespace private var animation
    
    var body: some View {
        ZStack {
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
                    let spacing: CGFloat = 12
                    let availableWidth = min(geometry.size.width - spacing * 4,
                                          DeviceAdaptation.GameVariant.set243.containerWidth)
                    let cardWidth = (availableWidth - spacing * 2) / 3
                    
                    let columns = [
                        GridItem(.fixed(cardWidth)),
                        GridItem(.fixed(cardWidth)),
                        GridItem(.fixed(cardWidth))
                    ]
                    
                    ScrollView {
                        if DeviceAdaptation.isIPad {
                            // Only center content on iPad
                            VStack {
                                Spacer(minLength: 0)
                                cardGridContent(columns: columns, spacing: spacing)
                                Spacer(minLength: 0)
                            }
                            .frame(minHeight: geometry.size.height)
                        } else {
                            // On phone, just show the grid directly
                            cardGridContent(columns: columns, spacing: spacing)
                        }
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
                        Button("Deal 3 Cards") {
                            withAnimation {
                                game.dealThreeCards()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .font(DeviceAdaptation.buttonFont)
                    }
                }
                .padding()
            }
                
            // Perfect set flash overlay
            .overlay {
                // Green flash overlay with synchronized timing
                if game.justFoundPerfectSet {
                    Color.green
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
        }
        // Single animation modifier for the entire ZStack
        .animation(.easeInOut(duration: 0.2), value: game.justFoundPerfectSet)
        .alert("Congratulations!", isPresented: $showingWinAlert) {
            Button("New Game") {
                game.startNewGame()
            }
            Button("Return to Menu") {
                navigationPath = NavigationPath()  // This cleanly returns to root
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
    private func cardGridContent(columns: [GridItem], spacing: CGFloat) -> some View {
        let cardWidth: CGFloat
        if case let .fixed(width) = columns[0].size {
            cardWidth = width
        } else {
            cardWidth = 0
        }
                
        return Group {
            if shouldUseSplitLayout(cardWidth: cardWidth, spacing: spacing) {
                // Two-column layout for overflow cases
                HStack(spacing: spacing * 2) {
                    // Left grid - first half of cards
                    cardGrid(columns: columns,
                            cards: Array(game.tableCards[..<(game.tableCards.count/2)]),
                            spacing: spacing,
                            namespace: animation)
                    
                    // Right grid - second half of cards
                    cardGrid(columns: columns,
                            cards: Array(game.tableCards[(game.tableCards.count/2)...]),
                            spacing: spacing,
                            namespace: animation)
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                // Standard single-column layout
                cardGrid(columns: columns,
                        cards: game.tableCards,
                        spacing: spacing,
                        namespace: animation)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .padding(.horizontal, spacing)
        .animation(.easeInOut(duration: 0.4), value: shouldUseSplitLayout(cardWidth: cardWidth, spacing: spacing))
        .animation(.easeInOut(duration: 0.2), value: game.tableCards)
        .adaptToDevice(.set243)
    }

    private func cardGrid(columns: [GridItem], cards: [Set243Card], spacing: CGFloat, namespace: Namespace.ID) -> some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(cards) { card in
                Set243CardView(card: card, isSelected: game.selectedCards.contains(card))
                    .aspectRatio(1.6, contentMode: .fit)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            game.selectCard(card)
                        }
                    }
                    .matchedGeometryEffect(id: card.id, in: namespace)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    ))
            }
        }
    }

    private func shouldUseSplitLayout(cardWidth: CGFloat, spacing: CGFloat) -> Bool {
        guard DeviceAdaptation.isIPad else { return false }
        
        // Get the orientation
        let orientation = UIDevice.current.orientation
        guard orientation.isLandscape else { return false }
        
        let cardHeight = cardWidth / 1.6
        let rowHeight = cardHeight + spacing
        let numberOfRows = ceil(Double(game.tableCards.count) / 3.0)
        let totalHeight = rowHeight * numberOfRows
        
        // Get screen height with safe area insets
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return false }
        
        let safeAreaHeight = window.safeAreaLayoutGuide.layoutFrame.height
        let heightThreshold = safeAreaHeight // screen height
        
        return totalHeight > heightThreshold
    }
}

struct Set243CardView: View {
    let card: Set243Card
    let isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardColor: Color {
        switch card.color {
            case 0: Color.red
            case 1: Color.green
            default: Color.purple
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let shapeWidth = min(geometry.size.width * 0.2, 50)            
            let shapeHeight = shapeWidth * 1.6
            
            ZStack {
                // Outer card with selection border
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? .black : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(isSelected ? .blue : .gray, lineWidth: isSelected ? 2 : 0)
                    )
                
                // Feature border (2pt, colored, matches card art color)
                Group {
                    switch card.border {
                    case 0:  // Single line
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(cardColor, lineWidth: DeviceAdaptation.isIPad ? 3.5 : 2)
                    case 1:  // Dotted
                        //old dotted impl:
                        /*
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(cardColor,
                                        style: StrokeStyle(lineWidth: DeviceAdaptation.isIPad ? 4 : 2.5, dash: DeviceAdaptation.isIPad ? [5] : [2]))
                                // Two-line option
                                /*.strokeBorder(cardColor, lineWidth: 2)
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(cardColor, lineWidth: 2)
                                .padding(3)*/
                        } */
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cardColor, style: StrokeStyle(
                                lineWidth: DeviceAdaptation.isIPad ? 4 : 3,
                                lineCap: .round,
                                lineJoin: .round,
                                miterLimit: 0,
                                dash: [0.01, DeviceAdaptation.isIPad ? 6 : 5],
                                dashPhase: 0
                            ))
                    case 2:  // Dashed
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cardColor,
                                    style: StrokeStyle(lineWidth: DeviceAdaptation.isIPad ? 3.5 : 2, dash: DeviceAdaptation.isIPad ? [14] : [9]))
                    default:
                        EmptyView()
                    }
                }
                .padding(4)
                
                // Card symbols
                let positions = calculateShapePositions(
                    count: card.number + 1,
                    containerWidth: geometry.size.width,
                    shapeWidth: shapeWidth
                )
                
                ForEach(0..<card.number + 1, id: \.self) { index in
                    cardSymbol
                        .frame(width: shapeWidth, height: shapeHeight)
                        .position(x: positions[index].x, y: geometry.size.height / 2)
                }
            }
        }
    }
    
    private func calculateShapePositions(count: Int, containerWidth: CGFloat, shapeWidth: CGFloat) -> [CGPoint] {
        let spacing = shapeWidth * 0.3
        let totalGroupWidth = CGFloat(count) * shapeWidth + CGFloat(count - 1) * spacing
        let startX = (containerWidth - totalGroupWidth) / 2 + shapeWidth / 2
        
        return (0..<count).map { index in
            CGPoint(x: startX + CGFloat(index) * (shapeWidth + spacing), y: 0)
        }
    }
    
    @ViewBuilder
    private var cardSymbol: some View {
        let shape = switch card.shape {
            case 0: AnyShape(Diamond())
            case 1: AnyShape(Capsule().scale(x: 0.9, y: 1))
            default: AnyShape(SetSquiggle())
        }
        
        let color = switch card.color {
            case 0: Color.red
            case 1: Color.green
            default: Color.purple
        }
        
        switch card.shading {
            case 0:  // Outlined
                shape.stroke(color, lineWidth: DeviceAdaptation.isIPad ? 3 : 2)
            case 1:  // Striped
                ZStack {
                    shape.stroke(color, lineWidth: 2)
                    StripedShapeContent(color: color)
                        .mask(shape)
                }
            default:  // Solid
                shape.fill(color)
        }
    }
}

#Preview {
    NavigationStack {
        Set243GameView(navigationPath: .constant(NavigationPath()))
    }
}
