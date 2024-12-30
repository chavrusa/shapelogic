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
    @Published private(set) var justFoundPerfectSet = false
    
    private static let allCards: [Set243Card] = {
        var cards: [Set243Card] = []
        for i in 0..<243 {
            cards.append(Set243Card(
                number: i%3,
                shape: (i%9)/3,
                color: (i%27)/9,
                shading: (i%81)/27,
                border: (i%243)/81
            ))
        }
        return cards
    }()
    
    var score: Int { (243 - drawPile.count - tableCards.count ) / 3 }
    var isGameOver: Bool { drawPile.isEmpty && !hasSet() }
    
    init() {
        // Start with empty state
        drawPile = []
        tableCards = []
        selectedCards = []
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
    
    func deal(_ dealAnyway: Bool) {
        guard drawPile.count >= 3 else { return }
        if (tableCards.count > 12) && hasSet() && !dealAnyway { return }
                
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
        }
        
        else if selectedCards.count < 3 {
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
            // Check for perfect set before modifying table
            let isPerfect = (0...4).allSatisfy { property in
                let values = cards.map { $0.properties[property] }
                return Set(values).count == 3  // All different
            }
            
            // Remove set from table
            tableCards.removeAll { cards.contains($0) }
            // Put down more (will not deal if not needed)
            deal(false)
            
            // Trigger animation if perfect
            if isPerfect {
                justFoundPerfectSet = true
                HapticManager.shared.perfectSetFound()
                // Reset after brief delay
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                    justFoundPerfectSet = false
                }
            }
        }
        else {
            HapticManager.shared.invalidSetAttempted()
        }
        // Clear selection once cards are processed
        selectedCards.removeAll()
    }
    
    func startNewGame() {
        // Reset game state
        drawPile = Set243Game.allCards.shuffled()
        tableCards = []
        selectedCards = []
        
        // Setup initial board
        deal(false)
    }
}
