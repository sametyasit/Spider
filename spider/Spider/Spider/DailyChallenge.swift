//
//  DailyChallenge.swift
//  Spider
//
//  Created by Samet on 01/05/2025.
//

import Foundation

struct DailyChallenge {
    let date: Date
    let seed: Int
    let difficulty: DifficultyLevel
    let name: String
    var isCompleted: Bool = false
    var bestScore: Int = 0
    var bestTime: TimeInterval = 0
    
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
        
        return DailyChallenge(
            date: today, 
            seed: seed, 
            difficulty: difficulty, 
            name: name
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
            
            // Check if this challenge is already completed
            var challenge = DailyChallenge(date: currentDate, seed: seed, difficulty: difficulty, name: name)
            
            // Check saved completion status
            let dateKey = dateFormatter.string(from: currentDate)
            if let completed = UserDefaults.standard.value(forKey: "challenge_completed_\(dateKey)") as? Bool {
                challenge.isCompleted = completed
            }
            
            if let score = UserDefaults.standard.value(forKey: "challenge_score_\(dateKey)") as? Int {
                challenge.bestScore = score
            }
            
            if let time = UserDefaults.standard.value(forKey: "challenge_time_\(dateKey)") as? Double {
                challenge.bestTime = time
            }
            
            challenges.append(challenge)
            
            // Move to next day
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return challenges
    }
    
    // Save the result of completing this challenge
    func saveCompletion(score: Int, time: TimeInterval) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateKey = dateFormatter.string(from: date)
        
        UserDefaults.standard.set(true, forKey: "challenge_completed_\(dateKey)")
        
        // Update best score if higher
        let currentBest = UserDefaults.standard.integer(forKey: "challenge_score_\(dateKey)")
        if score > currentBest {
            UserDefaults.standard.set(score, forKey: "challenge_score_\(dateKey)")
        }
        
        // Update best time if faster or first completion
        let currentBestTime = UserDefaults.standard.double(forKey: "challenge_time_\(dateKey)")
        if currentBestTime == 0 || time < currentBestTime {
            UserDefaults.standard.set(time, forKey: "challenge_time_\(dateKey)")
        }
        
        // Save total challenges completed
        let totalCompleted = UserDefaults.standard.integer(forKey: "total_challenges_completed")
        UserDefaults.standard.set(totalCompleted + 1, forKey: "total_challenges_completed")
    }
} 