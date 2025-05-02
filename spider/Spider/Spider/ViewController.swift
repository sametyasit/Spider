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
        
        // Oyun ayarlarını yükle
        GameConfig.loadSettings()
        
        // Kısa bir gecikme ile yeni oyunu otomatik başlat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.spiderView.startNewGame()
            
            // Debug bilgisi yazdır
            print("Oyun başlatıldı - Zorluk: \(GameConfig.difficultyLevel.rawValue)")
        }
    }
    
    private func setupUI() {
        print("Arayüz kurulumu başlıyor...")
        
        // Oyun görünümünü oluştur ve ekle
        spiderView = SpiderSolitaireView(frame: view.bounds)
        spiderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Arka plan rengini ayarla - tema rengine göre
        let theme = GameConfig.themes[GameConfig.currentTheme] ?? GameConfig.themes["Klasik"]!
        view.backgroundColor = theme.background
        
        view.addSubview(spiderView)
        print("SpiderSolitaireView oluşturuldu ve eklendi")
        
        // Ayarlar düğmesini ayarla
        setupSettingsButton()
        
        // Tema düğmesini ayarla
        setupThemeButton()
        
        // Meydan okuma düğmesini ayarla (opsiyonel)
        setupChallengeButton()
    }
    
    private func setupSettingsButton() {
        // Ayarlar düğmesi - sağ üst köşede
        settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        settingsButton.layer.cornerRadius = 20
        
        // Şık görgü ve stil
        settingsButton.frame = CGRect(x: view.bounds.width - 50, y: 40, width: 40, height: 40)
        settingsButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        
        // Gölge ekle
        settingsButton.layer.shadowColor = UIColor.black.cgColor
        settingsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        settingsButton.layer.shadowOpacity = 0.3
        settingsButton.layer.shadowRadius = 3
        
        // Tıklama efekti ekle
        settingsButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        settingsButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Ayarlar menüsünü gösterme işlemi
        settingsButton.addTarget(self, action: #selector(showSettingsMenu), for: .touchUpInside)
        
        view.addSubview(settingsButton)
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.9
        }
        
        // Dokunsal geri bildirim
        if GameConfig.hapticFeedbackEnabled {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
    
    @objc private func showSettingsMenu() {
        // Ayarlar menüsünü oluştur
        let alertController = UIAlertController(title: "Ayarlar", message: nil, preferredStyle: .actionSheet)
        
        // Zorluk seviyesi seçenekleri
        alertController.addAction(UIAlertAction(title: "Kolay (Tek Takım)", style: .default) { _ in
            GameConfig.difficultyLevel = .easy
            GameConfig.saveSettings()
            self.spiderView.startNewGame()
        })
        
        alertController.addAction(UIAlertAction(title: "Orta (İki Takım)", style: .default) { _ in
            GameConfig.difficultyLevel = .medium
            GameConfig.saveSettings()
            self.spiderView.startNewGame()
        })
        
        alertController.addAction(UIAlertAction(title: "Zor (Dört Takım)", style: .default) { _ in
            GameConfig.difficultyLevel = .hard
            GameConfig.saveSettings()
            self.spiderView.startNewGame()
        })
        
        // Ses ve titreşim ayarları
        let soundTitle = GameConfig.soundEnabled ? "Sesi Kapat" : "Sesi Aç"
        alertController.addAction(UIAlertAction(title: soundTitle, style: .default) { _ in
            GameConfig.soundEnabled.toggle()
            GameConfig.saveSettings()
        })
        
        let hapticTitle = GameConfig.hapticFeedbackEnabled ? "Titreşimi Kapat" : "Titreşimi Aç"
        alertController.addAction(UIAlertAction(title: hapticTitle, style: .default) { _ in
            GameConfig.hapticFeedbackEnabled.toggle()
            GameConfig.saveSettings()
        })
        
        // Yeni oyun başlatma seçeneği
        alertController.addAction(UIAlertAction(title: "Yeni Oyun", style: .default) { _ in
            self.spiderView.startNewGame()
        })
        
        // İptal seçeneği
        alertController.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        // iPad için popup kaynağı ayarla
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = settingsButton
            popoverController.sourceRect = settingsButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupThemeButton() {
        // Tema düğmesi - sol üst köşe
        themeButton = UIButton(type: .system)
        themeButton.setImage(UIImage(systemName: "paintpalette"), for: .normal)
        themeButton.tintColor = .white
        themeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        themeButton.layer.cornerRadius = 20
        
        // Şık görünüm ve stil
        themeButton.frame = CGRect(x: 10, y: 40, width: 40, height: 40)
        themeButton.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        
        // Gölge ekle
        themeButton.layer.shadowColor = UIColor.black.cgColor
        themeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        themeButton.layer.shadowOpacity = 0.3
        themeButton.layer.shadowRadius = 3
        
        // Tıklama efekti ekle
        themeButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        themeButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Tema menüsünü gösterme işlemi
        themeButton.addTarget(self, action: #selector(showThemeMenu), for: .touchUpInside)
        
        view.addSubview(themeButton)
    }
    
    @objc private func showThemeMenu() {
        // Tema menüsünü oluştur
        let alertController = UIAlertController(title: "Tema Seçin", message: nil, preferredStyle: .actionSheet)
        
        // Tüm temalar için aksiyon ekle
        for themeName in GameConfig.themes.keys.sorted() {
            let isCurrentTheme = themeName == GameConfig.currentTheme
            let title = isCurrentTheme ? "✓ \(themeName)" : themeName
            
            alertController.addAction(UIAlertAction(title: title, style: .default) { _ in
                GameConfig.currentTheme = themeName
                GameConfig.saveSettings()
                
                // Tema değiştiğinde arka planı güncelle
                let theme = GameConfig.themes[themeName]!
                UIView.animate(withDuration: 0.3) {
                    self.view.backgroundColor = theme.background
                    self.spiderView.updateTheme()
                }
            })
        }
        
        // İptal seçeneği
        alertController.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        // iPad için popup kaynağı ayarla
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = themeButton
            popoverController.sourceRect = themeButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func setupChallengeButton() {
        // Meydan okuma düğmesi - orta üst
        challengeButton = UIButton(type: .system)
        challengeButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        challengeButton.tintColor = .white
        challengeButton.backgroundColor = UIColor(red: 1.0, green: 0.76, blue: 0.03, alpha: 0.9)
        challengeButton.layer.cornerRadius = 20
        
        // Şık görünüm ve stil
        challengeButton.frame = CGRect(x: view.bounds.width / 2 - 20, y: 40, width: 40, height: 40)
        challengeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        
        // Gölge ekle
        challengeButton.layer.shadowColor = UIColor.black.cgColor
        challengeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        challengeButton.layer.shadowOpacity = 0.3
        challengeButton.layer.shadowRadius = 3
        
        // Tıklama efekti ekle
        challengeButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        challengeButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Meydan okuma menüsünü gösterme işlemi
        challengeButton.addTarget(self, action: #selector(showChallengeMenu), for: .touchUpInside)
        
        view.addSubview(challengeButton)
    }
    
    @objc private func showChallengeMenu() {
        // Günlük meydan okuma menüsünü oluştur
        let alertController = UIAlertController(title: "Günlük Meydan Okuma", message: "Özel hazırlanmış zorluklar", preferredStyle: .actionSheet)
        
        // Günlük meydan okuma
        alertController.addAction(UIAlertAction(title: "Bugünün Meydan Okuması", style: .default) { _ in
            // Bugünün meydan okumasını başlat
            self.startDailyChallenge()
        })
        
        // Önceki meydan okumalar
        alertController.addAction(UIAlertAction(title: "Meydan Okuma Arşivi", style: .default) { _ in
            // Arşiv ekranını göster
            self.showChallengeArchive()
        })
        
        // İptal seçeneği
        alertController.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        // iPad için popup kaynağı ayarla
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = challengeButton
            popoverController.sourceRect = challengeButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func startDailyChallenge() {
        // Bugünün tarihinden deterministik bir seed oluştur
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        let seed = (components.year ?? 2025) * 10000 + (components.month ?? 1) * 100 + (components.day ?? 1)
        
        // Günlük meydan okumanın adını oluştur
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.locale = Locale(identifier: "tr_TR")
        let challengeName = "\(dateFormatter.string(from: today))"
        
        // Meydan okuma verisini oluştur ve oyunu başlat
        let challenge = GameConfig.DailyChallenge(
            id: seed,
            name: challengeName,
            difficulty: .medium,
            seed: seed
        )
        
        spiderView.startDailyChallenge(challenge: challenge)
        
        // Bildirim göster
        let alert = UIAlertController(
            title: "Günlük Meydan Okuma Başladı",
            message: "\(challengeName) meydan okuması! Bu özel hazırlanmış oyunu tamamlayarak günlük ödül kazanın!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    private func showChallengeArchive() {
        // Arşiv ekranı için basit bir alert göster
        let alert = UIAlertController(
            title: "Meydan Okuma Arşivi",
            message: "Bu özellik yakında eklenecek!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    // Kartları yeniden konumlandırma yardımcısı
    func yenidenKonumlandir() {
        for stack in spiderView.stacks {
            stack.repositionCards()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

