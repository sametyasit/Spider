//
//  GameConfig.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

// MARK: - Game Configuration

class GameConfig {
    // Different difficulty levels
    enum DifficultyLevel: String, CaseIterable {
        case easy = "Kolay"   // 1 suit
        case medium = "Orta"  // 2 suits
        case hard = "Zor"     // 4 suits
        
        var description: String {
            switch self {
            case .easy:
                return "Kolay - Tek takım"
            case .medium:
                return "Orta - İki takım"
            case .hard:
                return "Zor - Dört takım"
            }
        }
    }
    
    // Daily challenge class
    class DailyChallenge {
        let id: Int
        let name: String
        let difficulty: DifficultyLevel
        let seed: Int
        let date: Date
        
        init(id: Int, name: String, difficulty: DifficultyLevel, seed: Int, date: Date = Date()) {
            self.id = id
            self.name = name
            self.difficulty = difficulty
            self.seed = seed
            self.date = date
        }
        
        func saveCompletion(score: Int, time: TimeInterval) {
            UserDefaults.standard.set(score, forKey: "challenge_\(id)_score")
            UserDefaults.standard.set(time, forKey: "challenge_\(id)_time")
            UserDefaults.standard.set(true, forKey: "challenge_\(id)_completed")
        }
        
        var isCompleted: Bool {
            return UserDefaults.standard.bool(forKey: "challenge_\(id)_completed")
        }
        
        // Generate a daily challenge for today
        static func forToday() -> DailyChallenge {
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: today)
            
            // Get day of year for seed
            let calendar = Calendar.current
            let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 0
            let year = calendar.component(.year, from: today)
            
            // Create predictable seed for this day
            let seed = (year * 1000) + dayOfYear
            
            // Determine difficulty based on day of week
            let weekday = calendar.component(.weekday, from: today)
            let difficulty: DifficultyLevel
            
            switch weekday {
            case 1, 7:  // Weekend (Sunday, Saturday)
                difficulty = .hard
            case 2, 4, 6:  // Monday, Wednesday, Friday
                difficulty = .medium
            default:  // Tuesday, Thursday
                difficulty = .easy
            }
            
            // Generate a challenge name
            let names = [
                "Örümcek Ağı", 
                "Kart Ustası", 
                "Zorlayıcı Eller", 
                "Sabırlı Oyuncu", 
                "Zorlu Durum",
                "Takım Toplama", 
                "Stratejik Hamle"
            ]
            let nameIndex = dayOfYear % names.count
            let name = "\(dateString) - \(names[nameIndex])"
            
            // Create challenge with today's date encoded in the ID
            let id = year * 10000 + calendar.component(.month, from: today) * 100 + calendar.component(.day, from: today)
            
            return DailyChallenge(
                id: id,
                name: name,
                difficulty: difficulty,
                seed: seed,
                date: today
            )
        }
        
        // Generate list of daily challenges for the current month
        static func forCurrentMonth() -> [DailyChallenge] {
            let today = Date()
            let calendar = Calendar.current
            
            // Get the first day of the month
            let components = calendar.dateComponents([.year, .month], from: today)
            guard let firstDay = calendar.date(from: components) else { return [] }
            
            // Get the date for the first day of next month
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay) else { return [] }
            
            // Generate challenges for each day of the month
            var challenges: [DailyChallenge] = []
            var currentDate = firstDay
            
            while currentDate < nextMonth {
                // Create a challenge for this day
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: currentDate)
                
                // Get day of year for seed
                let dayOfYear = calendar.ordinality(of: .day, in: .year, for: currentDate) ?? 0
                let year = calendar.component(.year, from: currentDate)
                
                // Create predictable seed for this day
                let seed = (year * 1000) + dayOfYear
                
                // Determine difficulty based on day of week
                let weekday = calendar.component(.weekday, from: currentDate)
                let difficulty: DifficultyLevel
                
                switch weekday {
                case 1, 7:  // Weekend (Sunday, Saturday)
                    difficulty = .hard
                case 2, 4, 6:  // Monday, Wednesday, Friday
                    difficulty = .medium
                default:  // Tuesday, Thursday
                    difficulty = .easy
                }
                
                // Generate a challenge name
                let names = ["Örümcek Ağı", "Kart Ustası", "Zorlayıcı Eller", "Sabırlı Oyuncu", "Zorlu Durum"]
                let nameIndex = dayOfYear % names.count
                let name = "\(dateString) - \(names[nameIndex])"
                
                // Create challenge with date encoded in the ID
                let id = year * 10000 + calendar.component(.month, from: currentDate) * 100 + calendar.component(.day, from: currentDate)
                let challenge = DailyChallenge(
                    id: id, 
                    name: name, 
                    difficulty: difficulty, 
                    seed: seed, 
                    date: currentDate
                )
                
                challenges.append(challenge)
                
                // Move to next day
                guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDay
            }
            
            return challenges
        }
    }
    
    // Current difficulty level
    static var difficultyLevel: DifficultyLevel = .easy
    
    // Card dimensions - adjusted for better visibility
    static let cardWidth: CGFloat = 70.0
    static let cardHeight: CGFloat = 100.0
    static let cardOverlap: CGFloat = 25.0
    
    // Card margins
    static let horizontalMargin: CGFloat = 15.0
    static let verticalMargin: CGFloat = 30.0
    static let stackSpacing: CGFloat = 8.0
    
    // Number of stacks
    static let numberOfStacks = 10
    
    // Card values and suits
    static let cardValues = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    
    // Card suits based on emoji
    static let allSuits = ["♠️", "♥️", "♦️", "♣️"]
    
    // Suit colors
    static let suitColors: [String: UIColor] = [
        "♠️": .black,
        "♣️": .black,
        "♥️": .red,
        "♦️": .red
    ]
    
    // Game themes
    static let themes: [String: (background: UIColor, cardBack: UIColor, pattern: String)] = [
        "Klasik": (UIColor(hex: "#1B5E20"), UIColor(hex: "#2E7D32"), "🕸️"),
        "Mavi": (UIColor(hex: "#1A237E"), UIColor(hex: "#303F9F"), "🌊"),
        "Karanlık": (UIColor(hex: "#212121"), UIColor(hex: "#424242"), "🌙"),
        "Mor": (UIColor(hex: "#4A148C"), UIColor(hex: "#6A1B9A"), "⚜️"),
        "Kırmızı": (UIColor(hex: "#B71C1C"), UIColor(hex: "#C62828"), "🔥"),
    ]
    
    // Current theme
    static var currentTheme: String = "Klasik"
    
    // Animations
    static let moveAnimationDuration: TimeInterval = 0.3
    static let flipAnimationDuration: TimeInterval = 0.3
    static let completeAnimationDuration: TimeInterval = 0.5
    static let dealAnimationDuration: TimeInterval = 0.2
    
    // Accessibility features
    static var soundEnabled = true
    static var hapticFeedbackEnabled = true
    static var largeTextEnabled = false
    static var highContrastEnabled = false
    
    // Orta zorluk için aynı takımdan olma kuralı (opsiyonel, bazı oyunlar daha sıkı kurallar kullanabilir)
    static var requireSameSuitForMedium = false
    
    // Oyun ayarları
    static var showTimer = true
    static var showScore = true
    
    // Puan sistemi
    static let completeSequencePoints = 100
    static let moveCardPoints = 5
    
    // Kart takımları fonksiyonu (önceki suitsForCurrentDifficulty fonksiyonunu hala kullanalım)
    static var cardSuits: [String] {
        return suitsForCurrentDifficulty()
    }
    
    // Kart durumu için struct
    struct CardState: Codable {
        let value: String
        let suit: String
        let isRevealed: Bool
    }
    
    // Game Manager for handling game persistence
    class GameManager {
        static let shared = GameManager()
        
        private init() {}
        
        // Save game state
        func saveGame(score: Int, moves: Int, elapsedTime: TimeInterval, difficultyLevel: DifficultyLevel, completedSetCount: Int, stacks: [CardStack], stockPileCount: Int, seed: Int?, isChallenge: Bool) {
            
            // Kart durumlarını kaydet
            var gameState = [[[String: Any]]]()
            
            for stack in stacks {
                var stackState = [[String: Any]]()
                
                for card in stack.cards {
                    let cardState: [String: Any] = [
                        "value": card.value,
                        "suit": card.suit,
                        "isRevealed": card.isRevealed
                    ]
                    stackState.append(cardState)
                }
                
                gameState.append(stackState)
            }
            
            // Oyun durumunu kaydet
            UserDefaults.standard.set(score, forKey: "savedGameScore")
            UserDefaults.standard.set(moves, forKey: "savedGameMoves")
            UserDefaults.standard.set(elapsedTime, forKey: "savedGameTime")
            UserDefaults.standard.set(difficultyLevel.rawValue, forKey: "savedGameDifficulty")
            UserDefaults.standard.set(completedSetCount, forKey: "savedGameCompletedSets")
            UserDefaults.standard.set(stockPileCount, forKey: "savedGameStockPileCount")
            UserDefaults.standard.set(gameState, forKey: "savedGameStacks")
            UserDefaults.standard.set(isChallenge, forKey: "savedGameIsChallenge")
            
            if let gameSeed = seed {
                UserDefaults.standard.set(gameSeed, forKey: "savedGameSeed")
            }
            
            UserDefaults.standard.set(true, forKey: "hasSavedGame")
        }
        
        // Check if there's a saved game
        func hasSavedGame() -> Bool {
            return UserDefaults.standard.bool(forKey: "hasSavedGame")
        }
        
        // Load saved game
        func loadSavedGame() -> (score: Int, moves: Int, elapsedTime: TimeInterval, difficultyLevel: DifficultyLevel, completedSetCount: Int, cards: [[(value: String, suit: String, isRevealed: Bool)]], stockPileCount: Int, seed: Int?, isChallenge: Bool)? {
            
            guard hasSavedGame() else { return nil }
            
            let score = UserDefaults.standard.integer(forKey: "savedGameScore")
            let moves = UserDefaults.standard.integer(forKey: "savedGameMoves")
            let elapsedTime = UserDefaults.standard.double(forKey: "savedGameTime")
            let completedSetCount = UserDefaults.standard.integer(forKey: "savedGameCompletedSets")
            let stockPileCount = UserDefaults.standard.integer(forKey: "savedGameStockPileCount")
            let isChallenge = UserDefaults.standard.bool(forKey: "savedGameIsChallenge")
            
            // Zorluk seviyesini yükle
            var difficultyLevel = DifficultyLevel.easy
            if let difficultyString = UserDefaults.standard.string(forKey: "savedGameDifficulty"),
               let loadedDifficulty = DifficultyLevel(rawValue: difficultyString) {
                difficultyLevel = loadedDifficulty
            }
            
            // Kart durumlarını yükle ve tuple'lara dönüştür
            let cardsDict = UserDefaults.standard.array(forKey: "savedGameStacks") as? [[[String: Any]]] ?? []
            
            // Dictionary'leri tuple'lara dönüştür
            var cardTuples = [[(value: String, suit: String, isRevealed: Bool)]]()
            
            for stackDict in cardsDict {
                var stackTuples = [(value: String, suit: String, isRevealed: Bool)]()
                
                for cardDict in stackDict {
                    if let value = cardDict["value"] as? String,
                       let suit = cardDict["suit"] as? String,
                       let isRevealed = cardDict["isRevealed"] as? Bool {
                        stackTuples.append((value: value, suit: suit, isRevealed: isRevealed))
                    }
                }
                
                cardTuples.append(stackTuples)
            }
            
            // Seed değerini yükle (opsiyonel)
            let seed: Int? = UserDefaults.standard.object(forKey: "savedGameSeed") as? Int
            
            return (score, moves, elapsedTime, difficultyLevel, completedSetCount, cardTuples, stockPileCount, seed, isChallenge)
        }
        
        // Clear saved game
        func clearSavedGame() {
            UserDefaults.standard.removeObject(forKey: "savedGameScore")
            UserDefaults.standard.removeObject(forKey: "savedGameMoves")
            UserDefaults.standard.removeObject(forKey: "savedGameTime")
            UserDefaults.standard.removeObject(forKey: "savedGameDifficulty")
            UserDefaults.standard.removeObject(forKey: "savedGameCompletedSets")
            UserDefaults.standard.removeObject(forKey: "savedGameStockPileCount")
            UserDefaults.standard.removeObject(forKey: "savedGameStacks")
            UserDefaults.standard.removeObject(forKey: "savedGameSeed")
            UserDefaults.standard.removeObject(forKey: "savedGameIsChallenge")
            UserDefaults.standard.set(false, forKey: "hasSavedGame")
        }
        
        // Load statistics
        func loadStatistics() -> (gamesPlayed: Int, gamesWon: Int, bestScore: Int, fastestTime: TimeInterval) {
            let gamesPlayed = UserDefaults.standard.integer(forKey: "statisticsGamesPlayed")
            let gamesWon = UserDefaults.standard.integer(forKey: "statisticsGamesWon")
            let bestScore = UserDefaults.standard.integer(forKey: "statisticsBestScore")
            let fastestTime = UserDefaults.standard.double(forKey: "statisticsFastestTime")
            
            return (gamesPlayed, gamesWon, bestScore, fastestTime)
        }
        
        // Save statistics
        func saveStatistics(gamesPlayed: Int, gamesWon: Int, bestScore: Int, fastestTime: TimeInterval) {
            UserDefaults.standard.set(gamesPlayed, forKey: "statisticsGamesPlayed")
            UserDefaults.standard.set(gamesWon, forKey: "statisticsGamesWon")
            UserDefaults.standard.set(bestScore, forKey: "statisticsBestScore")
            UserDefaults.standard.set(fastestTime, forKey: "statisticsFastestTime")
        }
    }
    
    // Preferences Keys
    private static let difficultyKey = "SpiderDifficultyLevel"
    private static let themeKey = "SpiderTheme"
    private static let soundKey = "SpiderSound"
    private static let hapticKey = "SpiderHaptic"
    
    // Save Settings
    static func saveSettings() {
        UserDefaults.standard.set(difficultyLevel.rawValue, forKey: difficultyKey)
        UserDefaults.standard.set(currentTheme, forKey: themeKey)
        UserDefaults.standard.set(soundEnabled, forKey: soundKey)
        UserDefaults.standard.set(hapticFeedbackEnabled, forKey: hapticKey)
    }
    
    // Load Settings
    static func loadSettings() {
        if let difficultyString = UserDefaults.standard.string(forKey: difficultyKey),
           let loadedDifficulty = DifficultyLevel(rawValue: difficultyString) {
            difficultyLevel = loadedDifficulty
        }
        
        if let theme = UserDefaults.standard.string(forKey: themeKey), themes[theme] != nil {
            currentTheme = theme
        }
        
        soundEnabled = UserDefaults.standard.bool(forKey: soundKey)
        hapticFeedbackEnabled = UserDefaults.standard.bool(forKey: hapticKey)
    }
    
    // Reset Settings to Default
    static func resetToDefaults() {
        difficultyLevel = .easy
        currentTheme = "Klasik"
        soundEnabled = true
        hapticFeedbackEnabled = true
        saveSettings()
    }
    
    // Get suits based on difficulty
    static func suitsForCurrentDifficulty() -> [String] {
        switch difficultyLevel {
        case .easy:
            return [allSuits[0]] // Just spades
        case .medium:
            return Array(allSuits[0...1]) // Spades and hearts
        case .hard:
            return allSuits // All four suits
        }
    }
}

// Extension to help create color from hex
extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    // Make color darker
    func darker(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    // Make color lighter
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjust(by: abs(percentage) )
    }
    
    // Adjust color brightness
    private func adjust(by percentage: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return UIColor(
            red: min(r + percentage/100, 1.0),
            green: min(g + percentage/100, 1.0),
            blue: min(b + percentage/100, 1.0),
            alpha: a
        )
    }
} 