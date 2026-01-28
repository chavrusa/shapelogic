//
//  ClassicSetGame.swift
//  shapelogic
//
//  Created by arishal on 11/25/24.
//

import Foundation

struct Card: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let shape: Int
    let color: Int
    let shading: Int

    var properties: [Int] { [number, shape, color, shading] }
}

@MainActor
final class SetGame: ObservableObject {
    @Published private(set) var drawPile: [Card]
    @Published private(set) var tableCards: [Card]
    @Published private(set) var selectedCards: Set<Card>

    private let easterEggEnabled: Bool
    private var lastDealtCard: Card?

    private static let allCards: [Card] = {
        (0..<81).map { i in
            Card(
                number: i % 3,
                shape: (i / 3) % 3,
                color: (i / 9) % 3,
                shading: i / 27
            )
        }
    }()

    var score: Int { (81 - drawPile.count - tableCards.count) / 3 }
    var isGameOver: Bool { drawPile.isEmpty && !hasSet() }

    init(easterEggEnabled: Bool = false) {
        self.easterEggEnabled = easterEggEnabled
        drawPile = []
        tableCards = []
        selectedCards = []
        startNewGame()
    }

    func isLastCard(_ card: Card) -> Bool {
        easterEggEnabled && lastDealtCard == card
    }

    static func isSet(_ cards: [Card]) -> Bool {
        guard cards.count == 3 else { return false }
        return (0..<4).allSatisfy { property in
            cards.map { $0.properties[property] }.reduce(0, +) % 3 == 0
        }
    }

    func hasSet() -> Bool {
        guard tableCards.count >= 3 else { return false }
        if tableCards.count == 3 {
            return SetGame.isSet(tableCards)
        }

        for i in 0..<tableCards.count - 2 {
            for j in (i + 1)..<tableCards.count - 1 {
                for k in (j + 1)..<tableCards.count {
                    if SetGame.isSet([tableCards[i], tableCards[j], tableCards[k]]) {
                        return true
                    }
                }
            }
        }
        return false
    }

    func dealThreeCards() {
        guard drawPile.count >= 3 else { return }
        let newCards = drawPile.suffix(3)
        drawPile.removeLast(3)
        if drawPile.isEmpty {
            lastDealtCard = newCards.last
        }
        tableCards.append(contentsOf: newCards)
    }

    func ensureValidTable() {
        while tableCards.count < 12 && drawPile.count >= 3 {
            dealThreeCards()
        }
        while !hasSet() && drawPile.count >= 3 {
            dealThreeCards()
        }
    }

    func selectCard(_ card: Card) {
        HapticManager.shared.cardSelected()

        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else if selectedCards.count < 3 {
            selectedCards.insert(card)
            if selectedCards.count == 3 {
                processSelectedCards()
            }
        }
    }

    private func processSelectedCards() {
        let cards = Array(selectedCards)
        if SetGame.isSet(cards) {
            HapticManager.shared.validSetFound()
            tableCards.removeAll { cards.contains($0) }
            ensureValidTable()
        } else {
            HapticManager.shared.invalidSetAttempted()
        }
        selectedCards.removeAll()
    }

    func startNewGame() {
        drawPile = Self.allCards.shuffled()
        tableCards = []
        selectedCards = []
        lastDealtCard = nil
        ensureValidTable()
    }
}
