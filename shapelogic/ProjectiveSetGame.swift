//
//  ProjectiveSetGame.swift
//  shapelogic
//
//  Created by arishal on 11/26/24.
//

import Foundation

struct ProjectiveCard: Identifiable, Hashable {
    let id = UUID()
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

    private static let requiredTableCards = 7

    private static let allCards: [ProjectiveCard] = {
        (1...63).map { i in
            ProjectiveCard(features: (0..<6).map { bit in
                (i >> bit) & 1 == 1
            })
        }
    }()

    var score: Int { 63 - drawPile.count - tableCards.count }
    var isGameOver: Bool { drawPile.isEmpty && tableCards.isEmpty }

    init() {
        drawPile = []
        tableCards = []
        selectedCards = []
        startNewGame()
    }

    static func isSet(_ cards: [ProjectiveCard]) -> Bool {
        guard !cards.isEmpty else { return false }
        return (0..<6).allSatisfy { featureIndex in
            cards.filter { $0.hasFeature(featureIndex) }.count % 2 == 0
        }
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
        maintainTableCards()
        selectedCards.removeAll()
    }

    private func maintainTableCards() {
        while tableCards.count < Self.requiredTableCards && !drawPile.isEmpty {
            tableCards.append(drawPile.removeLast())
        }
    }

    func startNewGame() {
        drawPile = Self.allCards.shuffled()
        tableCards = []
        selectedCards = []

        for _ in 0..<Self.requiredTableCards {
            tableCards.append(drawPile.removeLast())
        }
    }
}
