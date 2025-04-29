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
    
    // Card dimensions - smaller for portrait mode
    static let cardWidth: CGFloat = 60.0
    static let cardHeight: CGFloat = 85.0
    static let cardOverlap: CGFloat = 20.0
    
    // Card margins
    static let horizontalMargin: CGFloat = 10.0
    static let verticalMargin: CGFloat = 10.0
    static let stackSpacing: CGFloat = 5.0
    
    // Animation speeds
    static let dealAnimationDuration: TimeInterval = 0.2
    static let moveAnimationDuration: TimeInterval = 0.3
    
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
} 