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

struct GameMenuItem<Accessory: View>: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    let accessory: Accessory
    
    init(
        title: String,
        subtitle: String,
        action: @escaping () -> Void,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.accessory = accessory()
    }
    
    var body: some View {
        HStack {
            GameButton(title: title, subtitle: subtitle, action: action)
            accessory
                .padding(.trailing)
        }
        .frame(height: 85)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(18)
    }
}

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
                VStack(spacing: 16) {
                    GameMenuItem(
                        title: "Classic Set",
                        subtitle: "81 cards, 4 features",
                        action: { navigationPath.append(GameRoute.classicSet(easterEgg: classicSetEasterEgg)) }
                    ) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Toggle("", isOn: $classicSetEasterEgg)
                                .labelsHidden()
                                .tint(.cyan)
                            Text("Easter egg")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 80)  // Fixed width for toggle column
                    }
                    
                    GameButton(
                        title: "Set-243",
                        subtitle: "243 cards, 5 features",
                        action: { navigationPath.append(GameRoute.set243) }
                    )
                    .frame(height: 85)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(18)
                    
                    GameButton(
                        title: "Projective Set",
                        subtitle: "63 cards, 6 binary features",
                        action: { navigationPath.append(GameRoute.projectiveSet) }
                    )
                    .frame(height: 85)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(18)
                    
                    GameButton(
                        title: "Four-State Set",
                        subtitle: "64 cards, 4 values per feature",
                        action: { navigationPath.append(GameRoute.fourStateSet) }
                    )
                    .frame(height: 85)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(18)
                    
                }
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

