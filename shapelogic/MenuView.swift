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
//    let howToPlay: String
//    let scoring: String
    let examples: [String]
}

// Constants for game rules
struct GameRulesets {
    static let classicSet = GameRules(
        title: "Classic Set (𝔽₃⁴)",
        objective: "Find all the sets.",
        setup: "The deck is made of 81 (3⁴) cards. Each card has four features: a shape (diamond, squiggle, or oval), color (red, green, or purple), fill (solid, shaded, or empty), and number (one, two, or three), each of which has three possible values. A set is three cards where for each trait, it is either all the same or all different between the three cards. The board has 12 cards by default, more will be dealt automatically if there is no set.",
        examples: [
            "✅ Valid set: One solid purple oval, two solid purple ovals, three solid purple ovals",
            "✅ Valid set: One shaded red diamond, two solid green squiggles, three empty purple ovals",
            "❌ Invalid set: One empty green squiggle, two empty green squiggles, three solid green squiggles"
        ]
    )
    
    static let set243 = GameRules(
        title: "Set-243 (𝔽₃⁵)",
        objective: "Find all the sets.",
        setup: "The deck contains 243 (3⁵) cards. Each card has five features: shape (diamond, squiggle, or oval), color (red, green, or purple), fill (solid, shaded, or empty), number (one, two, or three), and border style (lined, dashed, or dotted). A set, similarly to Classic Set, is three cards where each feature is either all the same or all different. The board has 12 cards by default, more will be dealt automatically if there is no set.",
        examples: [
            "✅ Valid set: One dot-borderd solid purple oval, two dot-bodered empty purple ovals, three dot-borderd shaded purple ovals",
            "✅ Valid set: One dash-bordered shaded red diamond, two dot-bordered solid green squiggles, three line-bordered empty purple ovals",
            "❌ Invalid set: One line-bordered empty green squiggle, two line-bordered empty green squiggles, three dot-borderd empty green squiggles"
        ]
    )
    
    static let projectiveSet = GameRules(
        title: "Projective Set (𝔽₂⁶)",
        objective: "Find all the sets.",
        setup: "The deck contains 63 (2⁶-1) cards. Each card has six dots on it, which are either present or absent (we have only 63 cards because the empty card is not included). Each dot has a consistent position and color, for ease of play. A set is any number of cards where for each dot, it appears an even number of times across your selected cards. The board always has seven cards, which are guaranteed to contain a set.",
        examples: [
            "✅ Valid set: [1, 2, 3] + [1, [], []] + [[], 2, 3]",
            """
            ✅ Valid set:
            [1, 2, 3, 4, 5, 6] +
            [[], 2, [], [], [], 6] +
            [1, 2, 3, 4, [], 6] +
            [[], [], [], [], 5, 6] +
            [[], 2, 3, [], [], 6] +
            [[], [], 3, [], [], 6]
            """,
            "❌ Invalid set: [1, 2, 3] + [[], 2, 3] + [1, [], 3]"
        ]
    )
    
    static let fourStateSet = GameRules(
        title: "Four State Set (𝔽₄³)",
        objective: "Find all the sets.",
        setup: "The deck contains 64 (4³) cards. Each card has three features: color (red, blue, green, or purple), fill (solid, shaded, crossed, or empty), and number (one, two, three, or four). A set is four cards where each feature is either all the same or all different. The board has 12 cards by default, more will be dealt automatically if there is no set.",
        examples: [
            "✅ Valid set: One solid red, one solid blue, one solid green, one solid purple",
            "✅ Valid set: One solid red, two crossed blues, three shaded greens, four empty purples",
            "❌ Invalid set: Three solid reds, two crossed blues, three shaded greens, three empty purples"
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
                    ForEach(rules.examples, id: \.self) { example in
                        Text(example)
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

