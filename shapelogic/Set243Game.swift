//
//  Set243Game.swift
//  shapelogic
//
//  Created by arishal on 11/27/24.
//

import Foundation

struct Set243Card: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let shape: Int
    let color: Int
    let shading: Int
    let border: Int

    var properties: [Int] { [number, shape, color, shading, border] }
}

@MainActor
final class Set243Game: ObservableObject {
    @Published private(set) var drawPile: [Set243Card]
    @Published private(set) var tableCards: [Set243Card]
    @Published private(set) var selectedCards: Set<Set243Card>
    @Published private(set) var justFoundPerfectSet = false

    private static let allCards: [Set243Card] = {
        (0..<243).map { i in
            Set243Card(
                number: i % 3,
                shape: (i / 3) % 3,
                color: (i / 9) % 3,
                shading: (i / 27) % 3,
                border: i / 81
            )
        }
    }()

    var score: Int { (243 - drawPile.count - tableCards.count) / 3 }
    var isGameOver: Bool { drawPile.isEmpty && !hasSet() }

    init() {
        drawPile = []
        tableCards = []
        selectedCards = []
        startNewGame()
    }

    static func isSet(_ cards: [Set243Card]) -> Bool {
        guard cards.count == 3 else { return false }
        return (0..<5).allSatisfy { property in
            cards.map { $0.properties[property] }.reduce(0, +) % 3 == 0
        }
    }

    func hasSet() -> Bool {
        guard tableCards.count >= 3 else { return false }

        for i in 0..<tableCards.count - 2 {
            for j in (i + 1)..<tableCards.count - 1 {
                for k in (j + 1)..<tableCards.count {
                    if Set243Game.isSet([tableCards[i], tableCards[j], tableCards[k]]) {
                        return true
                    }
                }
            }
        }
        return false
    }

    func deal(_ force: Bool) {
        guard drawPile.count >= 3 else { return }
        if tableCards.count > 12 && hasSet() && !force { return }

        // Insert cards at random positions for visual variety
        for card in drawPile.suffix(3) {
            let randomIndex = Int.random(in: 0...tableCards.count)
            tableCards.insert(card, at: randomIndex)
        }
        drawPile.removeLast(3)

        deal(false)
    }

    func selectCard(_ card: Set243Card) {
        HapticManager.shared.cardSelected()

        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else if selectedCards.count < 3 {
            selectedCards.insert(card)
        }

        if selectedCards.count == 3 {
            processSelectedCards()
        }
    }

    private func processSelectedCards() {
        let cards = Array(selectedCards)

        if Set243Game.isSet(cards) {
            HapticManager.shared.validSetFound()

            // Check for perfect set (all features different)
            let isPerfect = (0..<5).allSatisfy { property in
                Set(cards.map { $0.properties[property] }).count == 3
            }

            tableCards.removeAll { cards.contains($0) }
            deal(false)

            if isPerfect {
                justFoundPerfectSet = true
                HapticManager.shared.perfectSetFound()
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    justFoundPerfectSet = false
                }
            }
        } else {
            HapticManager.shared.invalidSetAttempted()
        }

        selectedCards.removeAll()
    }

    func startNewGame() {
        drawPile = Self.allCards.shuffled()
        tableCards = []
        selectedCards = []
        deal(false)
    }
}
