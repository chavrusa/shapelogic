//
//  ClassicSetGameView.swift
//  set
//
//  Created by arishal on 11/25/24.
//

import SwiftUI

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width * 0.8  // Matched to capsule width
        let height = rect.height
        let centerX = rect.midX
        let centerY = rect.midY
        
        path.move(to: CGPoint(x: centerX, y: centerY - height/2))
        path.addLine(to: CGPoint(x: centerX + width/2, y: centerY))
        path.addLine(to: CGPoint(x: centerX, y: centerY + height/2))
        path.addLine(to: CGPoint(x: centerX - width/2, y: centerY))
        path.closeSubpath()
        return path
    }
}

struct SetSquiggle: Shape {
    func path(in rect: CGRect) -> Path {
        let originalWidth: CGFloat = 250
        let originalHeight: CGFloat = 480
        
        let scaleX = rect.width / originalWidth
        let scaleY = rect.height / originalHeight
        let scale = min(scaleX, scaleY)
        
        let xOffset = (rect.width - originalWidth * scale) / 2
        let yOffset = (rect.height - originalHeight * scale) / 2
        
        let transform = CGAffineTransform(translationX: xOffset, y: yOffset)
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
        
        var path = Path()
        // Normalized x coordinates to span 0-250 instead of 200-500
        path.move(to: CGPoint(x: 102, y: 6.07))
        path.addCurve(
            to: CGPoint(x: 250, y: 155.29),
            control1: CGPoint(x: 166, y: 6.07),
            control2: CGPoint(x: 250, y: 54.35)
        )
        path.addCurve(
            to: CGPoint(x: 185, y: 310),
            control1: CGPoint(x: 250, y: 220.29),
            control2: CGPoint(x: 187, y: 264.48)
        )
        path.addCurve(
            to: CGPoint(x: 250, y: 420.22),
            control1: CGPoint(x: 183, y: 362.35),
            control2: CGPoint(x: 250, y: 387.52)
        )
        path.addCurve(
            to: CGPoint(x: 148, y: 474.06),
            control1: CGPoint(x: 250, y: 452.92),
            control2: CGPoint(x: 200, y: 474.06)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: 324.96),
            control1: CGPoint(x: 84, y: 474.06),
            control2: CGPoint(x: 0, y: 425.63)
        )
        path.addCurve(
            to: CGPoint(x: 69, y: 169),
            control1: CGPoint(x: 0, y: 259.96),
            control2: CGPoint(x: 66, y: 214.6)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: 60.2),
            control1: CGPoint(x: 71, y: 116.91),
            control2: CGPoint(x: 1, y: 92.51)
        )
        path.addCurve(
            to: CGPoint(x: 102, y: 6.07),
            control1: CGPoint(x: 0, y: 43.27),
            control2: CGPoint(x: 25, y: 6.07)
        )
        
        return path.applying(transform)
    }
}

struct StripedShapeContent: View {
    let color: Color
    
    var body: some View {
        Canvas { context, size in
            let stripeWidth: CGFloat = 1
            let spacing: CGFloat = DeviceAdaptation.isIPad ? 3.5 : 2.5
            let totalHeight = size.height
            
            var y: CGFloat = 0
            while y < totalHeight {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(color), lineWidth: 1)
                y += stripeWidth + spacing
            }
        }
    }
}

struct SetGameView: View {
    @StateObject private var game: SetGame
    @State private var showingWinAlert = false
    @Binding var navigationPath: NavigationPath
    
    init(navigationPath: Binding<NavigationPath>, easterEggEnabled: Bool) {
        _navigationPath = navigationPath
        _game = StateObject(wrappedValue: SetGame(easterEggEnabled: easterEggEnabled))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            scoreHeader
            remainingCardsText
            cardGrid
            gameButtons
        }
        .alert("Congratulations!", isPresented: $showingWinAlert) {
            winAlertButtons
        } message: {
            Text("You've found all the sets!")
        }
        .onChange(of: game.isGameOver) { _, isOver in
            if isOver {
                showingWinAlert = true
            }
        }
        .adaptToDevice(.classic)
    }
    
    private var scoreHeader: some View {
        Text("Score: \(game.score)")
            .font(.title2.bold())
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .systemGray6))
            .adaptiveHeader()
    }
    
    private var remainingCardsText: some View {
        Group {
            if !game.drawPile.isEmpty {
                Text("\(game.drawPile.count) cards remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var cardGrid: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 12
            let availableWidth = min(geometry.size.width - spacing * 4,
                                   DeviceAdaptation.GameVariant.classic.containerWidth)
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
    }

    private func cardGridContent(columns: [GridItem], spacing: CGFloat) -> some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(game.tableCards) { card in
                CardView(
                    card: card,
                    isSelected: game.selectedCards.contains(card),
                    isHidden: game.isLastCard(card)
                )
                .aspectRatio(1.6, contentMode: .fit)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        game.selectCard(card)
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale(scale: 1.1).combined(with: .opacity)
                    )
                )
            }
        }
        .padding(.horizontal, spacing)
        .animation(.easeInOut(duration: 0.2), value: game.tableCards)
        .adaptToDevice(.classic)
    }
    
    private var gameButtons: some View {
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
    
    private var winAlertButtons: some View {
        Group {
            Button("New Game") {
                game.startNewGame()
            }
            Button("Return to Menu") {
                navigationPath = NavigationPath()
            }
        }
    }
}

struct CardView: View {
    let card: Card
    let isSelected: Bool
    let isHidden: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? .black : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isSelected ? .blue : .gray, lineWidth: isSelected ? 3 : 1)
                    )
                
                if isHidden {
                    // For hidden card, show solid cyan rectangle
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cyan)
                        .padding(4)
                } else {
                    // Existing card content
                    let shapeWidth = min(geometry.size.width * 0.2, 50)
                    let shapeHeight = shapeWidth * 1.6
                    
                    ZStack {
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
        }
    }
    
    private func calculateShapePositions(count: Int, containerWidth: CGFloat, shapeWidth: CGFloat) -> [CGPoint] {
        //let totalWidth = containerWidth * 0.8
        var positions: [CGPoint] = []
        
        switch count {
        case 1:
            positions.append(CGPoint(x: containerWidth / 2, y: 0))
        case 2:
            let spacing = shapeWidth * 0.3  // Reduced spacing for 2 shapes (was 0.5)
            let startX = (containerWidth - (2 * shapeWidth + spacing)) / 2 + shapeWidth / 2
            positions.append(CGPoint(x: startX, y: 0))
            positions.append(CGPoint(x: startX + shapeWidth + spacing, y: 0))
        case 3:
            let spacing = shapeWidth * 0.3  // Reduced spacing for 3 shapes (was using totalWidth calculation)
            let totalGroupWidth = (3 * shapeWidth) + (2 * spacing)
            let startX = (containerWidth - totalGroupWidth) / 2 + shapeWidth / 2
            positions.append(CGPoint(x: startX, y: 0))
            positions.append(CGPoint(x: startX + shapeWidth + spacing, y: 0))
            positions.append(CGPoint(x: startX + 2 * (shapeWidth + spacing), y: 0))
        default:
            break
        }
        
        return positions
    }
    
    @ViewBuilder
    private var cardSymbol: some View {
        let color = switch card.color {
            case 0: Color.red
            case 1: Color.green
            default: Color.purple
        }
        
        let shape = switch card.shape {
            case 0: AnyShape(Diamond())
            case 1: AnyShape(Capsule().scale(x: 0.9, y: 1))
            default: AnyShape(SetSquiggle())
        }
        
        switch card.shading {
            case 0:  // Outlined
            shape.stroke(color, lineWidth: DeviceAdaptation.isIPad ? 3 : 2)
            case 1:  // Striped
                ZStack {
                    shape.stroke(color, lineWidth: 2)  // Matched stroke width
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
        SetGameView(navigationPath: .constant(NavigationPath()), easterEggEnabled: false)
    }
}
