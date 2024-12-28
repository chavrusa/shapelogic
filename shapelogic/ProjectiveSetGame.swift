//
//  ProjectiveSetGame.swift
//  set
//
//  Created by arishal on 11/26/24.
//

import Foundation

struct ProjectiveCard: Identifiable, Hashable {
    let id = UUID()
    // Index corresponds to: [red, orange, yellow, green, blue, purple]
    let features: [Bool]
    
    func hasFeature(_ index: Int) -> Bool {
        features[index]
    }
}

@MainActor
final class ProjectiveSetGame: ObservableObject {
    @Published private(set) var drawPile: [ProjectiveCard]
    @Published private(set) var tableCards: [ProjectiveCard]
    @Published private(set) var selectedCards: Set<ProjectiveCard>
    
    private let requiredTableCards = 7
    
    // Score is total number of cards collected, not number of sets
    var score: Int { 81 - drawPile.count - tableCards.count }
    
    // Game is only over when we can't maintain table cards and no sets are possible
    var isGameOver: Bool { drawPile.isEmpty && tableCards.isEmpty }
    
    init() {
        drawPile = []
        tableCards = []
        selectedCards = []
        startNewGame()
    }
    
    static func isSet(_ cards: [ProjectiveCard]) -> Bool {
        guard !cards.isEmpty else { return false }
        
        let featureSums = (0..<6).map { featureIndex in
            cards.filter { $0.hasFeature(featureIndex) }.count
        }
        
        return featureSums.allSatisfy { $0 % 2 == 0 }
    }
    
    func selectCard(_ card: ProjectiveCard) {
        HapticManager.shared.cardSelected()
        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else {
            selectedCards.insert(card)
            if selectedCards.count >= 3 && ProjectiveSetGame.isSet(Array(selectedCards)) {
                HapticManager.shared.validSetFound()
                processSelectedSet()
            }
        }
    }
    
    private func processSelectedSet() {
        let cards = Array(selectedCards)
        tableCards.removeAll { cards.contains($0) }
        
        // Try to maintain 7 cards if possible
        maintainTableCards()
        
        selectedCards.removeAll()
    }
    
    private func maintainTableCards() {
        while tableCards.count < requiredTableCards && !drawPile.isEmpty {
            let card = drawPile.removeLast()
            tableCards.append(card)
        }
    }
    
    func startNewGame() {
        var allCards: [ProjectiveCard] = []
        for i in 1...63 {
            var features: [Bool] = []
            var num = i
            for _ in 0..<6 {
                features.append(num % 2 == 1)
                num /= 2
            }
            allCards.append(ProjectiveCard(features: features))
        }
        
        drawPile = allCards.shuffled()
        tableCards = []
        selectedCards = []
        
        // Initial deal of exactly 7 cards
        for _ in 0..<requiredTableCards {
            let card = drawPile.removeLast()
            tableCards.append(card)
        }
    }
}
