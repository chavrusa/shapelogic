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

// Data structure to hold game rules
struct GameRules {
    let title: String
    let objective: String
    let setup: String
    let howToPlay: String
    let scoring: String
    let examples: [String]
}

// Constants for game rules
struct GameRulesets {
    static let classicSet = GameRules(
        title: "Classic Set",
        objective: "Find sets of three cards where each feature is either all the same or all different across the cards.",
        setup: "Game starts with 12 cards dealt from a deck of 81 cards. Each card has four features (number, shape, color, and shading) with three possible values each.",
        howToPlay: """
        • Select three cards that form a valid set
        • For each feature (number, shape, color, shading):
          - All cards must have the same value, OR
          - All cards must have different values
        • When a set is found, cards are removed and replaced
        • Request additional cards if no sets are visible
        """,
        scoring: "One point for each set found. Game ends when all sets are collected.",
        examples: [
            "Valid set: Three red solid ovals (all same number, shape, color, shading)",
            "Valid set: One red diamond, two green squiggles, three purple ovals (all features different)",
            "Invalid set: Two red diamonds, one green diamond (mixed same/different numbers)"
        ]
    )
    
    static let set243 = GameRules(
        title: "Set-243",
        objective: "Find sets of three cards following classic Set rules, now with an additional border feature.",
        setup: "Game starts with 12 cards dealt from a deck of 243 cards (3⁵). Each card has five features (number, shape, color, shading, and border style).",
        howToPlay: """
        • Follow classic Set rules with the fifth border feature
        • Perfect sets (where all features are different) trigger a special animation
        • Border styles can be solid, dashed, or dotted
        """,
        scoring: "One point for each set found. Perfect sets are worth the same but are visually celebrated.",
        examples: [
            "Valid set: Three cards with all same features except different borders",
            "Perfect set: All five features are different across the three cards",
            "Invalid set: Two solid borders, one dashed (mixed same/different)"
        ]
    )
    
    static let projectiveSet = GameRules(
        title: "Projective Set",
        objective: "Find sets where each color appears an even number of times across selected cards.",
        setup: "Game starts with 7 cards dealt from a deck of 63 cards. Each card shows a unique combination of colored dots.",
        howToPlay: """
        • Select any number of cards (typically 3-7)
        • Cards form a set if each color appears an even number of times
        • Selected cards are removed when they form a set
        • New cards are dealt to maintain 7 cards when possible
        """,
        scoring: "Score is based on total cards collected, not number of sets.",
        examples: [
            "Valid set: Three cards where red appears 2 times, blue 4 times, etc.",
            "Valid set: Four cards where each color appears exactly twice",
            "Invalid set: Three cards where red appears 3 times"
        ]
    )
    
    static let fourStateSet = GameRules(
        title: "Four State Set",
        objective: "Find sets of four cards where each feature is all the same or all different.",
        setup: "Game starts with 12 cards dealt from a deck of 64.",
        howToPlay: """
        • Select four cards that form a valid set
        • For each feature (number, shape, color):
          - All cards must have the same value, OR
          - All cards must have four different values
        • When a set is found, cards are removed and replaced
        • Request additional cards if no sets are visible
        """,
        scoring: "One point for each set found. Game ends when all sets are collected.",
        examples: [
            "Valid set: Four red circles (all same shape, color; four different numbers)",
            "Valid set: Four cards with all different shapes, colors, and numbers",
            "Invalid set: Three different colors and one repeated (must be all same or all different)"
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
                    ruleSection("Setup", content: rules.setup)
                    ruleSection("How to Play", content: rules.howToPlay)
                    ruleSection("Scoring", content: rules.scoring)
                    
                    Text("Examples")
                        .font(.headline)
                    ForEach(rules.examples, id: \.self) { example in
                        Text("• " + example)
                            .padding(.leading)
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

