//
//  FourStateGame.swift
//  shapelogic
//
//  Created by arishal on 12/10/24.
//

import Foundation

struct FourStateCard: Identifiable, Hashable {
    let id = UUID()
    let color: Int
    let shape: Int
    let number: Int

    var properties: [Int] { [color, shape, number] }
}

@MainActor
final class FourStateGame: ObservableObject {
    @Published private(set) var drawPile: [FourStateCard]
    @Published private(set) var tableCards: [FourStateCard]
    @Published private(set) var selectedCards: Set<FourStateCard>

    private static let allCards: [FourStateCard] = {
        (0..<64).map { i in
            FourStateCard(
                color: i % 4,
                shape: (i / 4) % 4,
                number: i / 16
            )
        }
    }()

    var score: Int { (64 - drawPile.count - tableCards.count) / 4 }
    var isGameOver: Bool { drawPile.isEmpty && !hasSet() }

    init() {
        drawPile = []
        tableCards = []
        selectedCards = []
        startNewGame()
    }

    func startNewGame() {
        drawPile = Self.allCards.shuffled()
        tableCards = []
        selectedCards = []
        deal()
    }

    func deal() {
        guard drawPile.count >= 4 else { return }

        tableCards.append(contentsOf: drawPile.suffix(4))
        drawPile.removeLast(4)

        if tableCards.count < 12 || !hasSet() {
            deal()
        }
    }

    static func isSet(_ cards: [FourStateCard]) -> Bool {
        guard cards.count == 4 else { return false }
        return (0..<3).allSatisfy { property in
            let values = Set(cards.map { $0.properties[property] })
            return values.count == 1 || values.count == 4
        }
    }

    func hasSet() -> Bool {
        guard tableCards.count >= 4 else { return false }
        if tableCards.count == 4 {
            return FourStateGame.isSet(tableCards)
        }

        for i in 0..<tableCards.count - 3 {
            for j in (i + 1)..<tableCards.count - 2 {
                for k in (j + 1)..<tableCards.count - 1 {
                    for l in (k + 1)..<tableCards.count {
                        if FourStateGame.isSet([tableCards[i], tableCards[j], tableCards[k], tableCards[l]]) {
                            return true
                        }
                    }
                }
            }
        }
        return false
    }

    func selectCard(_ card: FourStateCard) {
        HapticManager.shared.cardSelected()

        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else if selectedCards.count < 4 {
            selectedCards.insert(card)
        }

        if selectedCards.count == 4 {
            let cards = Array(selectedCards)
            if FourStateGame.isSet(cards) {
                HapticManager.shared.validSetFound()
                tableCards.removeAll { cards.contains($0) }
                if tableCards.count < 12 || !hasSet() {
                    deal()
                }
            } else {
                HapticManager.shared.invalidSetAttempted()
            }
            selectedCards = []
        }
    }
}
