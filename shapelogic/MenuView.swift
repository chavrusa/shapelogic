//
//  MenuView.swift
//  set
//
//  Created by arishal on 11/27/24.
//

import Foundation
import SwiftUI

// Route enum defines all possible navigation destinations
enum GameRoute: Hashable {
    case classicSet(easterEgg: Bool)
    case projectiveSet
    case set243
    case fourStateSet
}

// Protocol for all card types to share common interface
protocol CardProtocol: Identifiable, Hashable { }
extension Card: CardProtocol { }
extension Set243Card: CardProtocol { }
extension ProjectiveCard: CardProtocol { }
extension FourStateCard: CardProtocol { }

struct GameRules {
    let title: String
    let objective: String
    let setup: String
    let examples: [ExampleSet]
}

struct ExampleSet {
    let isValid: Bool
    let cards: [any CardProtocol]
    let invalidIndices: Set<Int>  // Used only for invalid sets
    
    static func valid(_ cards: [any CardProtocol]) -> ExampleSet {
        ExampleSet(isValid: true, cards: cards, invalidIndices: [])
    }
    
    static func invalid(_ cards: [any CardProtocol], highlighting indices: Set<Int>) -> ExampleSet {
        ExampleSet(isValid: false, cards: cards, invalidIndices: indices)
    }
}

// Component to show a row of example cards
struct ExampleCardRow<T: CardProtocol>: View {
    let example: ExampleSet
    let cardView: (T, Bool) -> any View  // Function to create appropriate card view
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(example.cards.enumerated()), id: \.offset) { index, cardAny in
                let card = cardAny as! T  // Safe because we control the types
                AnyView(cardView(card, example.invalidIndices.contains(index)))
                    .frame(height: 80)  // Fixed height for consistent sizing
            }
        }
        .padding(.horizontal)
    }
}

// Extension to show an example card with potential invalid highlighting
extension View {
    func invalidHighlight(_ isInvalid: Bool) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.red.opacity(isInvalid ? 0.15 : 0))
        )
    }
}

// Updated game rulesets
struct GameRulesets {
    static let classicSet = GameRules(
        title: "Classic Set (𝔽₃⁴)",
        objective: "Find all the sets.",
        setup: "The deck is made of 81 (3⁴) cards. Each card has four features: a shape (diamond, squiggle, or oval), color (red, green, or purple), fill (solid, shaded, or empty), and number (one, two, or three), each of which has three possible values. A set is three cards where for each trait, it is either all the same or all different between the three cards. The board has 12 cards by default, more will be dealt automatically if there is no set.",
        examples: [
            // All same except number
            .valid([
                Card(number: 0, shape: 2, color: 1, shading: 0),
                Card(number: 1, shape: 2, color: 1, shading: 0),
                Card(number: 2, shape: 2, color: 1, shading: 0)
            ]),
            // All different
            .valid([
                Card(number: 0, shape: 0, color: 0, shading: 0),
                Card(number: 1, shape: 1, color: 1, shading: 1),
                Card(number: 2, shape: 2, color: 2, shading: 2)
            ]),
            // Invalid - mixed same/different for shape
            .invalid([
                Card(number: 0, shape: 0, color: 2, shading: 0),
                Card(number: 1, shape: 0, color: 2, shading: 0),
                Card(number: 2, shape: 1, color: 2, shading: 0)
            ], highlighting: [2])
        ]
    )
    
    static let set243 = GameRules(
        title: "Set-243 (𝔽₃⁵)",
        objective: "Find all the sets.",
        setup: "The deck contains 243 (3⁵) cards. Each card has five features: shape (diamond, squiggle, or oval), color (red, green, or purple), fill (solid, shaded, or empty), number (one, two, or three), and border style (lined, dashed, or dotted). A set, similarly to Classic Set, is three cards where each feature is either all the same or all different. The board has 12 cards by default, more will be dealt automatically if there is no set.",
        examples: [
            // All same except number
            .valid([
                Set243Card(number: 0, shape: 1, color: 2, shading: 1, border: 1),
                Set243Card(number: 1, shape: 1, color: 2, shading: 1, border: 1),
                Set243Card(number: 2, shape: 1, color: 2, shading: 1, border: 1)
            ]),
            // All different
            .valid([
                Set243Card(number: 0, shape: 2, color: 1, shading: 1, border: 2),
                Set243Card(number: 1, shape: 1, color: 2, shading: 0, border: 0),
                Set243Card(number: 2, shape: 0, color: 0, shading: 2, border: 1)
            ]),
            // Invalid - mixed same/different for border
            .invalid([
                Set243Card(number: 1, shape: 2, color: 1, shading: 1, border: 1),
                Set243Card(number: 1, shape: 2, color: 2, shading: 1, border: 1),
                Set243Card(number: 1, shape: 2, color: 3, shading: 2, border: 0)
            ], highlighting: [2])
        ]
    )
    
    static let projectiveSet = GameRules(
        title: "Projective Set (𝔽₂⁶)",
        objective: "Find all the sets.",
        setup: "The deck contains 63 (2⁶-1) cards. Each card has six dots on it, which are either present or absent (we have only 63 cards because the empty card is not included). Each dot has a consistent position and color, for ease of play. A set is any number of cards where for each dot, it appears an even number of times across your selected cards. The board always has seven cards, which are guaranteed to contain a set.",
        examples: [
            // Simple 3-card set
            .valid([
                ProjectiveCard(features: [true, true, true, false, false, false]),
                ProjectiveCard(features: [true, false, false, true, true, false]),
                ProjectiveCard(features: [false, true, true, true, true, false])
            ]),
            // Complex 4-card set
            .valid([
                ProjectiveCard(features: [true, true, true, true, true, true]),
                ProjectiveCard(features: [false, true, false, false, false, true]),
                ProjectiveCard(features: [true, true, true, true, false, true]),
                ProjectiveCard(features: [false, true, true, false, true, false]),
                ProjectiveCard(features: [false, false, true, false, false, true])
            ]),
            // Invalid - odd number of first dot
            .invalid([
                ProjectiveCard(features: [true, true, true, false, false, false]),
                ProjectiveCard(features: [true, true, true, true, false, false]),
                ProjectiveCard(features: [false, false, false, true, false, true])
            ], highlighting: [2])
        ]
    )
    
    static let fourStateSet = GameRules(
        title: "Four-State Set (𝔽₄³)",
        objective: "Find all the sets.",
        setup: "The deck contains 64 (4³) cards. Each card has three features: color (red, blue, green, or purple), fill (solid, shaded, crossed, or empty), and number (one, two, three, or four). A set is four cards where each feature is either all the same or all different. The board has 12 cards by default, more will be dealt automatically if there is no set.",
        examples: [
            // All same except number
            .valid([
                FourStateCard(color: 0, shape: 0, number: 0),
                FourStateCard(color: 0, shape: 0, number: 1),
                FourStateCard(color: 0, shape: 0, number: 2),
                FourStateCard(color: 0, shape: 0, number: 3)
            ]),
            // All different
            .valid([
                FourStateCard(color: 0, shape: 0, number: 0),
                FourStateCard(color: 1, shape: 1, number: 1),
                FourStateCard(color: 2, shape: 2, number: 2),
                FourStateCard(color: 3, shape: 3, number: 3)
            ]),
            // Invalid - repeated number
            .invalid([
                FourStateCard(color: 1, shape: 1, number: 0),
                FourStateCard(color: 3, shape: 2, number: 1),
                FourStateCard(color: 2, shape: 3, number: 0),
                FourStateCard(color: 0, shape: 0, number: 0)
            ], highlighting: [1])
        ]
    )
}

// Rules sheet view
struct GameRulesSheet: View {
    let rules: GameRules
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ruleSection("Objective", content: rules.objective)
                    ruleSection("Rules", content: rules.setup)
                    
                    Text("Examples")
                        .font(.headline)
                    
                    VStack(spacing: 16) {
                        ForEach(Array(rules.examples.enumerated()), id: \.0) { index, example in
                            VStack(alignment: .center, spacing: 8) {
                                Text(example.isValid ? "✅ Valid" : "❌ Invalid")
                                    .font(.subheadline)
                                    .foregroundColor(example.isValid ? .primary : .red)
                                
                                if let classicCards = example.cards as? [Card] {
                                    ExampleCardRow(example: example) { card, isInvalid in
                                        CardView(card: card, isSelected: false, isHidden: false)
                                            .invalidHighlight(isInvalid)
                                    }
                                } else if let set243Cards = example.cards as? [Set243Card] {
                                    ExampleCardRow(example: example) { card, isInvalid in
                                        Set243CardView(card: card, isSelected: false)
                                            .invalidHighlight(isInvalid)
                                    }
                                } else if let projectiveCards = example.cards as? [ProjectiveCard] {
                                    ExampleCardRow(example: example) { card, isInvalid in
                                        ProjectiveCardView(card: card, isSelected: false, colors: [.red, .orange, .yellow, .green, .blue, .purple])
                                            .invalidHighlight(isInvalid)
                                    }
                                } else if let fourStateCards = example.cards as? [FourStateCard] {
                                    ExampleCardRow(example: example) { card, isInvalid in
                                        FourStateCardView(card: card, isSelected: false)
                                            .invalidHighlight(isInvalid)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(rules.title + " Rules")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func ruleSection(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
        }
    }
}


struct GameMenuItem: View {
    let title: String
    let subtitle: String
    let rules: GameRules
    let action: () -> Void
    var easterEggBinding: Binding<Bool>? = nil
    @State private var showingRules = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Info button on the left
            Button {
                showingRules = true
            } label: {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            
            // Main button with title and subtitle
            Button(action: action) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Easter egg toggle if binding is provided
            if let binding = easterEggBinding {
                VStack(alignment: .trailing, spacing: 4)  {
                    Toggle("", isOn: binding)
                        .labelsHidden()
                        .tint(.cyan)
                    Text("Easter egg")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
        .buttonStyle(.plain)
        .sheet(isPresented: $showingRules) {
            GameRulesSheet(rules: rules)
        }
    }
}
/*
struct GameButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .buttonStyle(.plain)
    }
} */

struct GameButton: View {
    let title: String
    let subtitle: String
    let rules: GameRules
    let action: () -> Void
    @State private var showingRules = false
    
    var body: some View {
        HStack {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2.bold())
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button {
                showingRules = true
            } label: {
                Image(systemName: "info.circle")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
        .buttonStyle(.plain)
        .sheet(isPresented: $showingRules) {
            GameRulesSheet(rules: rules)
        }
    }
}


struct MenuView: View {
    @Binding var navigationPath: NavigationPath
    @State private var classicSetEasterEgg = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Game mode")
                .font(.largeTitle.bold())
                .padding(.top, 32)
            
            VStack(spacing: 16) {
                GameMenuItem(
                    title: "Classic Set",
                    subtitle: "81 cards, 3 card sets",
                    rules: GameRulesets.classicSet,
                    action: { navigationPath.append(GameRoute.classicSet(easterEgg: classicSetEasterEgg)) },
                    easterEggBinding: $classicSetEasterEgg
                )
                .frame(maxWidth: 500)
                .padding(.horizontal)
                
                GameMenuItem(
                    title: "Set-243",
                    subtitle: "243 cards, 5 features, 3 card sets",
                    rules: GameRulesets.set243,
                    action: { navigationPath.append(GameRoute.set243) }
                )
                .frame(maxWidth: 500)
                .padding(.horizontal)
                
                GameMenuItem(
                    title: "Projective Set",
                    subtitle: "63 cards, arbitrary size sets",
                    rules: GameRulesets.projectiveSet,
                    action: { navigationPath.append(GameRoute.projectiveSet) }
                )
                .frame(maxWidth: 500)
                .padding(.horizontal)
                
                GameMenuItem(
                    title: "Four-State Set",
                    subtitle: "64 cards, 4 card sets",
                    rules: GameRulesets.fourStateSet,
                    action: { navigationPath.append(GameRoute.fourStateSet) }
                )
                .frame(maxWidth: 500)
                .padding(.horizontal)
            }
            Spacer()
        }
    }
}


// Back button component used in game views
struct BackButton: View {
    @Binding var showingAlert: Bool
    
    var body: some View {
        Button {
            showingAlert = true
        } label: {
            Image(systemName: "chevron.left")
                .imageScale(.large)
        }
    }
}

// Main navigation container that wraps the entire app
struct NavigationWrapper: View {
    @State private var navigationPath = NavigationPath()
    @State private var showingExitAlert = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            MenuView(navigationPath: $navigationPath)
                .navigationDestination(for: GameRoute.self) { route in
                    switch route {
                    case .classicSet(let easterEgg):
                        SetGameView(navigationPath: $navigationPath, easterEggEnabled: easterEgg)
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton(showingAlert: $showingExitAlert)
                                }
                            }
                    case .projectiveSet:
                        ProjectiveSetGameView(navigationPath: $navigationPath)
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton(showingAlert: $showingExitAlert)
                                }
                            }
                    case .set243:
                        Set243GameView(navigationPath: $navigationPath)
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton(showingAlert: $showingExitAlert)
                                }
                            }
                    case .fourStateSet:
                        FourStateSetGameView(navigationPath: $navigationPath)
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    BackButton(showingAlert: $showingExitAlert)
                                }
                            }
                    }
                }
        }
        .alert("End Current Game?", isPresented: $showingExitAlert) {
            Button("Keep Playing", role: .cancel) { }
            Button("Return to Menu", role: .destructive) {
                navigationPath = NavigationPath()
            }
        } message: {
            Text("Your progress will be lost.")
        }
    }
}

