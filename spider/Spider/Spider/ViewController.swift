//
//  ViewController.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

class ViewController: UIViewController {
    
    var spiderView: SpiderSolitaireView!
    private var settingsButton: UIButton!
    private var themeButton: UIButton!
    private var challengeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Create and add the main game view
        spiderView = SpiderSolitaireView(frame: view.bounds)
        spiderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(spiderView)
        
        // Add settings button
        setupSettingsButton()
        
        // Add theme button
        setupThemeButton()
        
        // Add challenge button
        setupChallengeButton()
    }
    
    private func setupSettingsButton() {
        settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        settingsButton.layer.cornerRadius = 20
        settingsButton.frame = CGRect(x: view.bounds.width - 50, y: view.safeAreaInsets.top + 10, width: 40, height: 40)
        settingsButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        view.addSubview(settingsButton)
    }
    
    private func setupThemeButton() {
        themeButton = UIButton(type: .system)
        themeButton.setImage(UIImage(systemName: "paintbrush"), for: .normal)
        themeButton.tintColor = .white
        themeButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        themeButton.layer.cornerRadius = 20
        themeButton.frame = CGRect(x: view.bounds.width - 100, y: view.safeAreaInsets.top + 10, width: 40, height: 40)
        themeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        themeButton.addTarget(self, action: #selector(showThemeSelector), for: .touchUpInside)
        view.addSubview(themeButton)
    }
    
    private func setupChallengeButton() {
        challengeButton = UIButton(type: .system)
        challengeButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        challengeButton.tintColor = .white
        challengeButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        challengeButton.layer.cornerRadius = 20
        challengeButton.frame = CGRect(x: view.bounds.width - 150, y: view.safeAreaInsets.top + 10, width: 40, height: 40)
        challengeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        challengeButton.addTarget(self, action: #selector(showDailyChallenges), for: .touchUpInside)
        view.addSubview(challengeButton)
    }
    
    @objc private func showSettings() {
        let settingsVC = UIAlertController(title: "Ayarlar", message: nil, preferredStyle: .actionSheet)
        
        // Difficulty settings
        settingsVC.addAction(UIAlertAction(title: "Zorluk: \(GameConfig.difficultyLevel.description)", style: .default) { _ in
            self.showDifficultySelector()
        })
        
        // Toggle settings
        settingsVC.addAction(UIAlertAction(title: GameConfig.showTimer ? "Süreyi Gizle" : "Süreyi Göster", style: .default) { _ in
            GameConfig.showTimer = !GameConfig.showTimer
            self.spiderView.updateSettings()
        })
        
        settingsVC.addAction(UIAlertAction(title: GameConfig.showScore ? "Puanı Gizle" : "Puanı Göster", style: .default) { _ in
            GameConfig.showScore = !GameConfig.showScore
            self.spiderView.updateSettings()
        })
        
        settingsVC.addAction(UIAlertAction(title: GameConfig.soundEnabled ? "Sesi Kapat" : "Sesi Aç", style: .default) { _ in
            GameConfig.soundEnabled = !GameConfig.soundEnabled
        })
        
        settingsVC.addAction(UIAlertAction(title: GameConfig.hapticFeedbackEnabled ? "Titreşimi Kapat" : "Titreşimi Aç", style: .default) { _ in
            GameConfig.hapticFeedbackEnabled = !GameConfig.hapticFeedbackEnabled
        })
        
        settingsVC.addAction(UIAlertAction(title: GameConfig.autoCompleteEnabled ? "Otomatik Tamamlamayı Kapat" : "Otomatik Tamamlamayı Aç", style: .default) { _ in
            GameConfig.autoCompleteEnabled = !GameConfig.autoCompleteEnabled
        })
        
        // New game action
        settingsVC.addAction(UIAlertAction(title: "Yeni Oyun", style: .destructive) { _ in
            self.showNewGameConfirmation()
        })
        
        // Stastics
        settingsVC.addAction(UIAlertAction(title: "İstatistikler", style: .default) { _ in
            self.showStatistics()
        })
        
        // Help action
        settingsVC.addAction(UIAlertAction(title: "Nasıl Oynanır", style: .default) { _ in
            self.showHowToPlay()
        })
        
        // Cancel action
        settingsVC.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        // For iPad
        if let popover = settingsVC.popoverPresentationController {
            popover.sourceView = settingsButton
            popover.sourceRect = settingsButton.bounds
        }
        
        present(settingsVC, animated: true)
    }
    
    private func showDifficultySelector() {
        let difficultyVC = UIAlertController(title: "Zorluk Seviyesi", message: "Bir zorluk seviyesi seçin", preferredStyle: .actionSheet)
        
        difficultyVC.addAction(UIAlertAction(title: "Kolay (1 Takım)", style: .default) { _ in
            GameConfig.difficultyLevel = .easy
            self.showNewGameConfirmation()
        })
        
        difficultyVC.addAction(UIAlertAction(title: "Orta (2 Takım)", style: .default) { _ in
            GameConfig.difficultyLevel = .medium
            self.showNewGameConfirmation()
        })
        
        difficultyVC.addAction(UIAlertAction(title: "Zor (4 Takım)", style: .default) { _ in
            GameConfig.difficultyLevel = .hard
            self.showNewGameConfirmation()
        })
        
        difficultyVC.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        // For iPad
        if let popover = difficultyVC.popoverPresentationController {
            popover.sourceView = settingsButton
            popover.sourceRect = settingsButton.bounds
        }
        
        present(difficultyVC, animated: true)
    }
    
    private func showNewGameConfirmation() {
        let alert = UIAlertController(
            title: "Yeni Oyun",
            message: "Mevcut oyunu sonlandırıp yeni bir oyun başlatmak istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Hayır", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Evet", style: .destructive) { _ in
            self.spiderView.startNewGame()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func showThemeSelector() {
        let themeVC = UIAlertController(title: "Tema Seçin", message: nil, preferredStyle: .actionSheet)
        
        for theme in GameConfig.themes.keys.sorted() {
            themeVC.addAction(UIAlertAction(title: theme, style: .default) { _ in
                GameConfig.currentTheme = theme
                self.spiderView.updateTheme()
            })
        }
        
        themeVC.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        // For iPad
        if let popover = themeVC.popoverPresentationController {
            popover.sourceView = themeButton
            popover.sourceRect = themeButton.bounds
        }
        
        present(themeVC, animated: true)
    }
    
    @objc private func showDailyChallenges() {
        let challengeVC = DailyChallengeViewController()
        challengeVC.modalPresentationStyle = .fullScreen
        present(challengeVC, animated: true)
    }
    
    private func showStatistics() {
        // Load saved statistics
        let stats = GameManager.shared.loadStatistics()
        
        // Format fastest time
        let fastestTimeMinutes = Int(stats.fastestTime) / 60
        let fastestTimeSeconds = Int(stats.fastestTime) % 60
        let timeString = stats.fastestTime > 0 ? String(format: "%02d:%02d", fastestTimeMinutes, fastestTimeSeconds) : "--:--"
        
        // Daily challenge stats
        let totalChallenges = UserDefaults.standard.integer(forKey: "total_challenges_completed")
        
        let alert = UIAlertController(
            title: "İstatistikler",
            message: """
            Toplam Oyunlar: \(stats.gamesPlayed)
            Kazanılan Oyunlar: \(stats.gamesWon)
            En Yüksek Puan: \(stats.bestScore)
            En Hızlı Oyun: \(timeString)
            
            Tamamlanan Meydan Okumalar: \(totalChallenges)
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func showHowToPlay() {
        let howToPlayVC = UIAlertController(
            title: "Nasıl Oynanır",
            message: """
            Spider Solitaire, kartları her bir takımda Papazdan Asa doğru sıralayarak oynadığınız bir kart oyunudur.
            
            • Kartları aynı takımda azalan sırada yerleştirebilirsiniz (örn. Kız, Vale, 10).
            • Farklı takımdan kartlar da yerleştirilebilir, ama yalnızca tam bir seri aynı takımda olduğunda tamamlanmış sayılır.
            • Boş bir sütuna herhangi bir kart yerleştirilebilir.
            • Tüm kartları sıraladığınızda oyunu kazanırsınız.
            
            İpucu: Önce aynı takımdan kartları bir araya getirmeye çalışın.
            """,
            preferredStyle: .alert
        )
        
        howToPlayVC.addAction(UIAlertAction(title: "Anladım", style: .default, handler: nil))
        present(howToPlayVC, animated: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

