//
//  ClassicSetGame.swift
//  set
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
    
    // Check if three cards make a set
    static func isSet(_ cards: [Card]) -> Bool {
        guard cards.count == 3 else { return false }
        return (0...3).allSatisfy { property in
            cards.map { $0.properties[property] }.reduce(0, +) % 3 == 0
        }
    }
    
    // Check if current table has any sets
    func hasSet() -> Bool {
        // Need at least 3 cards to make a set
        guard tableCards.count >= 3 else { return false }
        
        // For last 3 cards, just check them directly
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
    
    // Deal 3 cards from draw pile to table
    func dealThreeCards() {
        guard drawPile.count >= 3 else { return }
        let newCards = drawPile.suffix(3)
        drawPile.removeLast(3)
        // Track the first of the new cards if it's the last deal
        if drawPile.isEmpty {
            lastDealtCard = newCards.last
        }
        tableCards.append(contentsOf: newCards)
    }
    
    // Keep dealing until we have 12+ cards and at least one set
    func ensureValidTable() {
        // First ensure 12 cards if possible
        while tableCards.count < 12 && drawPile.count >= 3 {
            dealThreeCards()
        }
        
        // Then if no set exists, keep adding cards until we find one
        while !hasSet() && drawPile.count >= 3 {
            dealThreeCards()
        }
    }
    
    // Handle card selection
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
            // Remove set from table
            tableCards.removeAll { cards.contains($0) }
            // Ensure we maintain 12+ cards with a set
            ensureValidTable()
        }
        else {
            HapticManager.shared.invalidSetAttempted()
        }
        // Clear selection either way
        selectedCards.removeAll()
    }
    
    func startNewGame() {
        // Generate all 81 cards
        var allCards: [Card] = []
        for n in 0..<3 {
            for s in 0..<3 {
                for c in 0..<3 {
                    for sh in 0..<3 {
                        allCards.append(Card(number: n, shape: s,
                                          color: c, shading: sh))
                    }
                }
            }
        }
        
        // Reset game state
        drawPile = allCards.shuffled()
        tableCards = []
        selectedCards = []
        lastDealtCard = nil
        
        // Setup initial board
        ensureValidTable()
    }
}
