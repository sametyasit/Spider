//
//  GameConfig.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

enum DifficultyLevel: Int {
    case easy = 1   // 1 suit (only spades)
    case medium = 2 // 2 suits (spades and hearts)
    case hard = 4   // 4 suits (all suits)
    
    var description: String {
        switch self {
        case .easy: return "Kolay (1 Takım)"
        case .medium: return "Orta (2 Takım)"
        case .hard: return "Zor (4 Takım)"
        }
    }
}

struct GameConfig {
    // Current difficulty level
    static var difficultyLevel: DifficultyLevel = .easy
    
    // Card dimensions - adjusted for better visibility
    static let cardWidth: CGFloat = 75.0
    static let cardHeight: CGFloat = 110.0
    static let cardOverlap: CGFloat = 28.0
    
    // Card margins
    static let horizontalMargin: CGFloat = 20.0
    static let verticalMargin: CGFloat = 20.0
    static let stackSpacing: CGFloat = 12.0
    
    // Animation speeds
    static let dealAnimationDuration: TimeInterval = 0.2
    static let moveAnimationDuration: TimeInterval = 0.3
    static let flipAnimationDuration: TimeInterval = 0.3
    static let completeAnimationDuration: TimeInterval = 0.5
    
    // Game specific
    static let numberOfStacks: Int = 10
    static let cardsPerDeck: Int = 52
    static let maxHints: Int = 3
    
    // Card values and suits
    static let cardValues = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    static let cardSuits = ["♠", "♥", "♦", "♣"]
    static let suitColors: [String: UIColor] = [
        "♠": .black,
        "♥": .red,
        "♦": .red,
        "♣": .black
    ]
    
    // Themes
    static let themes: [String: (background: UIColor, cardBack: UIColor, pattern: String)] = [
        "Klasik": (UIColor(red: 0.15, green: 0.5, blue: 0.2, alpha: 1.0), UIColor(red: 0.0, green: 0.3, blue: 0.7, alpha: 1.0), "🕸️"),
        "Mavi": (UIColor(red: 0.0, green: 0.33, blue: 0.65, alpha: 1.0), UIColor(red: 0.0, green: 0.1, blue: 0.5, alpha: 1.0), "🌊"),
        "Kırmızı": (UIColor(red: 0.7, green: 0.12, blue: 0.15, alpha: 1.0), UIColor(red: 0.5, green: 0.05, blue: 0.05, alpha: 1.0), "🔥"),
        "Mor": (UIColor(red: 0.35, green: 0.1, blue: 0.5, alpha: 1.0), UIColor(red: 0.2, green: 0.0, blue: 0.35, alpha: 1.0), "🔮"),
        "Siyah": (UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0), UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0), "⚫"),
        "Altın": (UIColor(red: 0.65, green: 0.5, blue: 0.15, alpha: 1.0), UIColor(red: 0.7, green: 0.4, blue: 0.0, alpha: 1.0), "💰")
    ]
    
    // Current theme
    static var currentTheme: String = "Klasik"
    
    // Game features
    static var showTimer: Bool = true
    static var showMoves: Bool = true
    static var showScore: Bool = true
    static var soundEnabled: Bool = true
    static var hapticFeedbackEnabled: Bool = true
    static var autoCompleteEnabled: Bool = true
    
    // Daily challenges
    static let dailyChallengeRewardPoints: Int = 100
    
    // Scoring
    static let moveCardPoints: Int = 1
    static let completeSequencePoints: Int = 100
    static let gameCompletionBonus: Int = 500
    static let timePenaltyPerMinute: Int = 5
} 