//
//  Set243Game.swift
//  set
//  Set 243 variant game logic
//  Created by arishal on 11/27/24.
//

import Foundation

struct Set243Card: Identifiable, Hashable {
    let id = UUID()
    let number: Int      // Classic feature
    let shape: Int       // Classic feature
    let color: Int      // Classic feature
    let shading: Int    // Classic feature
    let border: Int     // New fifth feature!
    
    var properties: [Int] { [number, shape, color, shading, border] }
}

@MainActor
final class Set243Game: ObservableObject {
    @Published private(set) var drawPile: [Set243Card]
    @Published private(set) var tableCards: [Set243Card]
    @Published private(set) var selectedCards: Set<Set243Card>
    @Published private(set) var collectedCards: [Set243Card]
    @Published private(set) var justFoundPerfectSet = false
    
    var score: Int { collectedCards.count / 3 }
    var isGameOver: Bool { drawPile.isEmpty && !hasSet() }
    
    init() {
        // Start with empty state
        drawPile = []
        tableCards = []
        selectedCards = []
        collectedCards = []
        startNewGame()
    }
    
    // Check if three cards make a set
    static func isSet(_ cards: [Set243Card]) -> Bool {
        guard cards.count == 3 else { return false }
        // Check all 5 properties (including border)
        return (0...4).allSatisfy { property in
            cards.map { $0.properties[property] }.reduce(0, +) % 3 == 0
        }
    }
    
    // Helper for producing a green flash for perfect cards
    static func isPerfectSet(_ cards: [Set243Card]) -> Bool {
        guard cards.count == 3 else { return false }
        // Check each property - all must be different
        return (0...4).allSatisfy { property in
            let values = cards.map { $0.properties[property] }
            return Set(values).count == 3  // All different
        }
    }
    
    // Check if current table has any sets
    func hasSet() -> Bool {
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
    
    // Deal 3 cards from draw pile to table
    // Deal 3 cards from draw pile to table, inserting them at random positions
    func dealThreeCards() {
        guard drawPile.count >= 3 else { return }
        let newCards = drawPile.suffix(3)
        drawPile.removeLast(3)
        
        // For each new card, insert it at a random position in tableCards
        for card in newCards {
            let randomIndex = Int.random(in: 0...tableCards.count)
            tableCards.insert(card, at: randomIndex)
        }
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
    
    func selectCard(_ card: Set243Card) {
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
        if Set243Game.isSet(cards) {
            // Check for perfect set before modifying table
            let isPerfect = Set243Game.isPerfectSet(cards)
            
            // Remove set from table
            tableCards.removeAll { cards.contains($0) }
            // Add to collected cards
            collectedCards.append(contentsOf: cards)
            // Ensure we maintain 12+ cards with a set
            ensureValidTable()
            
            // Trigger animation if perfect
            if isPerfect {
                justFoundPerfectSet = true
                // Reset after brief delay
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                    justFoundPerfectSet = false
                }
            }
        }
        // Clear selection once cards are processed
        selectedCards.removeAll()
    }
    
    func startNewGame() {
        // Generate all 243 cards (3^5 combinations)
        var allCards: [Set243Card] = []
        for n in 0..<3 {
            for s in 0..<3 {
                for c in 0..<3 {
                    for sh in 0..<3 {
                        for b in 0..<3 {
                            allCards.append(Set243Card(
                                number: n,
                                shape: s,
                                color: c,
                                shading: sh,
                                border: b
                            ))
                        }
                    }
                }
            }
        }
        
        // Reset game state
        drawPile = allCards.shuffled()
        tableCards = []
        selectedCards = []
        collectedCards = []
        
        // Setup initial board
        ensureValidTable()
    }
}
