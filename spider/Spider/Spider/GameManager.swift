//
//  GameManager.swift
//  Spider
//
//  Created by Samet on 01/05/2025.
//

import Foundation

class GameManager {
    static let shared = GameManager()
    
    private struct GameState: Codable {
        var score: Int
        var moves: Int
        var elapsedTime: TimeInterval
        var difficultyLevel: Int
        var completedSetCount: Int
        var cardStates: [[CardState]]
        var stockPileCount: Int
        var currentTheme: String
        var seed: Int?
        var isChallenge: Bool
        
        struct CardState: Codable {
            var value: String
            var suit: String
            var isRevealed: Bool
            var stackIndex: Int
        }
    }
    
    // Save current game state
    func saveGame(
        score: Int,
        moves: Int,
        elapsedTime: TimeInterval,
        difficultyLevel: DifficultyLevel,
        completedSetCount: Int,
        stacks: [CardStack],
        stockPileCount: Int,
        seed: Int?,
        isChallenge: Bool
    ) {
        var cardStates: [[GameState.CardState]] = Array(repeating: [], count: stacks.count)
        
        // Save all cards by stack
        for (stackIndex, stack) in stacks.enumerated() {
            for card in stack.cards {
                let cardState = GameState.CardState(
                    value: card.value,
                    suit: card.suit,
                    isRevealed: card.isRevealed,
                    stackIndex: stackIndex
                )
                cardStates[stackIndex].append(cardState)
            }
        }
        
        let gameState = GameState(
            score: score,
            moves: moves,
            elapsedTime: elapsedTime,
            difficultyLevel: difficultyLevel.rawValue,
            completedSetCount: completedSetCount,
            cardStates: cardStates,
            stockPileCount: stockPileCount,
            currentTheme: GameConfig.currentTheme,
            seed: seed,
            isChallenge: isChallenge
        )
        
        // Encode and save
        if let encoded = try? JSONEncoder().encode(gameState) {
            UserDefaults.standard.set(encoded, forKey: "savedGameState")
            UserDefaults.standard.synchronize()
        }
    }
    
    // Check if there's a saved game
    func hasSavedGame() -> Bool {
        return UserDefaults.standard.data(forKey: "savedGameState") != nil
    }
    
    // Load saved game state
    private func loadGame() -> (
        score: Int,
        moves: Int,
        elapsedTime: TimeInterval,
        difficultyLevel: DifficultyLevel,
        completedSetCount: Int,
        cardStates: [[GameState.CardState]],
        stockPileCount: Int,
        seed: Int?,
        isChallenge: Bool
    )? {
        guard let data = UserDefaults.standard.data(forKey: "savedGameState"),
              let gameState = try? JSONDecoder().decode(GameState.self, from: data) else {
            return nil
        }
        
        // Set the theme
        GameConfig.currentTheme = gameState.currentTheme
        
        // Get the difficulty level
        let difficultyLevel = DifficultyLevel(rawValue: gameState.difficultyLevel) ?? .easy
        
        return (
            gameState.score,
            gameState.moves,
            gameState.elapsedTime,
            difficultyLevel,
            gameState.completedSetCount,
            gameState.cardStates,
            gameState.stockPileCount,
            gameState.seed,
            gameState.isChallenge
        )
    }
    
    // Clear saved game
    func clearSavedGame() {
        UserDefaults.standard.removeObject(forKey: "savedGameState")
        UserDefaults.standard.synchronize()
    }
    
    // Public method for loading saved game without exposing private types
    func loadSavedGame() -> (
        score: Int,
        moves: Int,
        elapsedTime: TimeInterval,
        difficultyLevel: DifficultyLevel,
        completedSetCount: Int,
        stockPileCount: Int,
        seed: Int?,
        isChallenge: Bool,
        cards: [[(value: String, suit: String, isRevealed: Bool, stackIndex: Int)]]
    )? {
        guard let savedData = loadGame() else {
            return nil
        }
        
        // Convert CardState to simple tuples
        let cardTuples = savedData.cardStates.map { stackCards in
            return stackCards.map { cardState in
                return (
                    value: cardState.value,
                    suit: cardState.suit,
                    isRevealed: cardState.isRevealed,
                    stackIndex: cardState.stackIndex
                )
            }
        }
        
        return (
            savedData.score,
            savedData.moves,
            savedData.elapsedTime,
            savedData.difficultyLevel,
            savedData.completedSetCount,
            savedData.stockPileCount,
            savedData.seed,
            savedData.isChallenge,
            cardTuples
        )
    }
    
    // Save player statistics
    func saveStatistics(gamesPlayed: Int, gamesWon: Int, bestScore: Int, fastestTime: TimeInterval) {
        UserDefaults.standard.set(gamesPlayed, forKey: "stat_gamesPlayed")
        UserDefaults.standard.set(gamesWon, forKey: "stat_gamesWon")
        
        // Only update best score if higher
        let currentBest = UserDefaults.standard.integer(forKey: "stat_bestScore")
        if bestScore > currentBest {
            UserDefaults.standard.set(bestScore, forKey: "stat_bestScore")
        }
        
        // Only update fastest time if faster and valid
        let currentFastest = UserDefaults.standard.double(forKey: "stat_fastestTime")
        if fastestTime > 0 && (currentFastest == 0 || fastestTime < currentFastest) {
            UserDefaults.standard.set(fastestTime, forKey: "stat_fastestTime")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    // Load player statistics
    func loadStatistics() -> (gamesPlayed: Int, gamesWon: Int, bestScore: Int, fastestTime: TimeInterval) {
        let gamesPlayed = UserDefaults.standard.integer(forKey: "stat_gamesPlayed")
        let gamesWon = UserDefaults.standard.integer(forKey: "stat_gamesWon")
        let bestScore = UserDefaults.standard.integer(forKey: "stat_bestScore")
        let fastestTime = UserDefaults.standard.double(forKey: "stat_fastestTime")
        
        return (gamesPlayed, gamesWon, bestScore, fastestTime)
    }
} 