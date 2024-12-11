import Foundation

// card with 3 properties each of which has 3 values
struct FourStateCard: Identifiable, Hashable {
    let id = UUID()
    let color: Int  // <4
    let shape: Int  // <4
    let number: Int // <4
    var properties: [Int] { [color, shape, number] }
}

@MainActor
final class FourStateGame: ObservableObject {
    @Published private(set) var drawPile: [FourStateCard]
    @Published private(set) var onTable: [FourStateCard]
    @Published private(set) var selectedCards: Set<FourStateCard>
    
    private static let AllCards: [FourStateCard] = {
        var cards: [FourStateCard] = []
        for i in 0..<64 {
            cards.append(FourStateCard(
                color: i%4,
                shape: (i%16)/4,
                number: (i%64)/16
            ))
        }
        return cards
    }()
    
    init() {
        drawPile = []
        onTable = []
        selectedCards = []
        startNewGame()
    }
    
    func startNewGame() {
        drawPile = Self.AllCards.shuffled()
        onTable = []
        selectedCards = []
        
        deal()
    }
    
    func deal() {
        if drawPile.count < 4 { return }
        
        onTable.append(contentsOf: drawPile.suffix(4))
        drawPile.removeLast(4)
        
        if onTable.count < 12 { deal() }
        if !hasSet() { deal() }
    }
    
    static func isSet(cards: [FourStateCard]) -> Bool {
        guard cards.count == 4 else { return false }
        // check each property
        for i in 0..<3 {
            let vals = Set(cards.map { $0.properties[i] })
            if vals.count != 1 && vals.count != 4 {
                return false
            }
        }
        return true
    }
    
    func hasSet() -> Bool {
        guard onTable.count >= 4 else { return false }
        if onTable.count == 4 { return FourStateGame.isSet(cards: onTable) }
        
        for i in 0..<onTable.count-3 {
            for j in (i+1)..<onTable.count-2 {
                for k in (j+1)..<onTable.count-1 {
                    for l in (k+1)..<onTable.count {
                        if FourStateGame.isSet(cards: [onTable[i], onTable[j], onTable[k], onTable[l]])
                        { return true }
                    }
                }
            }
        }
        return false
    }
    
    func selectCard(_ card: FourStateCard) {
        if selectedCards.contains(card) {
            selectedCards.remove(card)
        }
        else if selectedCards.count < 4 {
            selectedCards.insert(card)
        }
        if selectedCards.count == 4 {
            let cardsArray = Array(selectedCards)
            if FourStateGame.isSet(cards: cardsArray) {
                onTable.removeAll { cardsArray.contains($0) }
                if onTable.count < 12 { deal() }
                else if !hasSet() { deal() }
            }
        }
    }
}
