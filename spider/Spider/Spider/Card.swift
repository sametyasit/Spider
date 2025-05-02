//
//  Card.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

class Card: UIView {
    
    // MARK: - Properties
    
    internal let value: String
    internal let suit: String
    internal let faceUp: Bool
    
    private let frontView = UIView()
    private let backView = UIView()
    private var backPattern: UILabel!
    private var frontSuitLabel: UILabel!
    private var frontValueLabels: [UILabel] = []
    
    internal var isRevealed: Bool = false {
        didSet {
            updateCardFace()
        }
    }
    
    internal var isSelected: Bool = false {
        didSet {
            if isSelected {
                layer.borderWidth = 2.0
                layer.borderColor = UIColor.systemBlue.cgColor
                
                // Add glow effect
                layer.shadowColor = UIColor.systemBlue.cgColor
                layer.shadowOffset = .zero
                layer.shadowRadius = 5.0
                layer.shadowOpacity = 0.8
            } else {
                layer.borderWidth = 0.0
                layer.borderColor = UIColor.clear.cgColor
                
                // Remove glow effect
                layer.shadowOpacity = 0.0
            }
        }
    }
    
    internal var isDraggable: Bool = true // Set to true by default to enable dragging
    
    // MARK: - Initialization
    
    init(value: String, suit: String, faceUp: Bool = false) {
        self.value = value
        self.suit = suit
        self.faceUp = faceUp
        
        super.init(frame: CGRect(x: 0, y: 0, width: GameConfig.cardWidth, height: GameConfig.cardHeight))
        
        setupCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCard() {
        // Setup card appearance - daha basit
        clipsToBounds = false
        layer.cornerRadius = 8.0 // Daha profesyonel görünüm için köşeleri daha az yuvarla
        
        // Daha ince, şık gölge
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 1.5)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.3
        
        // Arka ve ön tarafları oluştur
        setupFrontAndBackViews()
        
        // Set initial state
        isRevealed = faceUp
    }
    
    private func setupFrontAndBackViews() {
        // Setup front view (face up)
        frontView.frame = bounds
        frontView.backgroundColor = .white
        frontView.layer.cornerRadius = 8.0
        frontView.layer.borderWidth = 0.5
        frontView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        frontView.clipsToBounds = true
        frontView.isHidden = !faceUp
        addSubview(frontView)
        setupCardFrontContent()
        
        // Setup back view (face down)
        backView.frame = bounds
        backView.layer.cornerRadius = 8.0
        backView.layer.borderWidth = 0.5
        backView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        backView.clipsToBounds = true
        backView.isHidden = faceUp
        addSubview(backView)
        setupCardBackContent()
    }
    
    private func setupCardFrontContent() {
        // Clear previous content if any
        for subview in frontView.subviews {
            subview.removeFromSuperview()
        }
        frontValueLabels.removeAll()
        
        // Beyaz arka plan
        frontView.backgroundColor = .white
        
        // Kart rengini belirle
        let color = GameConfig.suitColors[suit] ?? .black
        
        // Sol üst değer ve simge
        let topLabel = createValueLabel(position: .topLeft, color: color)
        frontView.addSubview(topLabel)
        frontValueLabels.append(topLabel)
        
        // Sağ alt değer ve simge (ters çevrilmiş)
        let bottomLabel = createValueLabel(position: .bottomRight, color: color)
        frontView.addSubview(bottomLabel)
        frontValueLabels.append(bottomLabel)
        
        // Ortadaki büyük simge
        frontSuitLabel = UILabel()
        frontSuitLabel.text = suit
        frontSuitLabel.textColor = color
        frontSuitLabel.font = UIFont.systemFont(ofSize: bounds.width * 0.6, weight: .medium)
        frontSuitLabel.textAlignment = .center
        frontSuitLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        
        // Simgeye hafif gölge ekle
        frontSuitLabel.layer.shadowColor = UIColor.black.cgColor
        frontSuitLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        frontSuitLabel.layer.shadowRadius = 1
        frontSuitLabel.layer.shadowOpacity = 0.2
        
        frontView.addSubview(frontSuitLabel)
        
        // J, Q, K kartlarına özel süslemeler ekle
        if ["J", "Q", "K"].contains(value) {
            addFaceCardDecorations(color: color)
        }
    }
    
    private func addFaceCardDecorations(color: UIColor) {
        let miniSuitSize: CGFloat = 10
        let margin: CGFloat = 15
        
        // Top row of mini suits
        for i in 0..<3 {
            let miniSuit = UILabel()
            miniSuit.text = suit
            miniSuit.textColor = color.withAlphaComponent(0.7)
            miniSuit.font = UIFont.systemFont(ofSize: miniSuitSize)
            miniSuit.textAlignment = .center
            miniSuit.frame = CGRect(
                x: bounds.width / 4 * CGFloat(i) + margin,
                y: bounds.height / 3,
                width: miniSuitSize,
                height: miniSuitSize
            )
            frontView.addSubview(miniSuit)
        }
        
        // Bottom row of mini suits
        for i in 0..<3 {
            let miniSuit = UILabel()
            miniSuit.text = suit
            miniSuit.textColor = color.withAlphaComponent(0.7)
            miniSuit.font = UIFont.systemFont(ofSize: miniSuitSize)
            miniSuit.textAlignment = .center
            miniSuit.frame = CGRect(
                x: bounds.width / 4 * CGFloat(i) + margin,
                y: bounds.height * 2/3,
                width: miniSuitSize,
                height: miniSuitSize
            )
            frontView.addSubview(miniSuit)
        }
    }
    
    private func setupCardBackContent() {
        // Clear previous content if any
        for subview in backView.subviews {
            subview.removeFromSuperview()
        }
        
        // Get current theme
        let theme = GameConfig.themes[GameConfig.currentTheme] ?? GameConfig.themes["Klasik"]!
        
        // Profesyonel görünüm için gradient arka plan
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backView.bounds
        gradientLayer.colors = [
            theme.cardBack.cgColor,
            theme.cardBack.darker(by: 20).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = backView.layer.cornerRadius
        backView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Daha profesyonel görünüm için çift çerçeveli desen
        let patternView = UIView(frame: CGRect(x: 4, y: 4, width: bounds.width - 8, height: bounds.height - 8))
        patternView.backgroundColor = UIColor.clear
        patternView.layer.cornerRadius = 6.0
        patternView.layer.borderWidth = 2.0
        patternView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        backView.addSubview(patternView)
        
        // İç çerçeve
        let innerBorder = UIView(frame: CGRect(x: 8, y: 8, width: bounds.width - 16, height: bounds.height - 16))
        innerBorder.backgroundColor = UIColor.clear
        innerBorder.layer.cornerRadius = 4.0
        innerBorder.layer.borderWidth = 1.0
        innerBorder.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backView.addSubview(innerBorder)
        
        // Kart sırtındaki desen (örümcek ya da başka simge)
        backPattern = UILabel(frame: innerBorder.bounds)
        backPattern.text = theme.pattern
        backPattern.textAlignment = .center
        backPattern.font = UIFont.systemFont(ofSize: min(bounds.width, bounds.height) * 0.4)
        backPattern.textColor = .white
        
        // Desene parlama efekti ekle
        backPattern.layer.shadowColor = UIColor.white.cgColor
        backPattern.layer.shadowRadius = 2
        backPattern.layer.shadowOpacity = 0.3
        backPattern.layer.shadowOffset = .zero
        
        innerBorder.addSubview(backPattern)
        
        // Süsleme: Köşelerde küçük desenler
        addBackPatternDecorations(theme: theme)
    }
    
    private func addBackPatternDecorations(theme: (background: UIColor, cardBack: UIColor, pattern: String)) {
        // Köşelerde ufak desenler ekle
        let miniSize = bounds.width * 0.15
        let margin = bounds.width * 0.08
        
        // Sol üst
        let topLeftPattern = UILabel()
        topLeftPattern.text = theme.pattern
        topLeftPattern.textAlignment = .center
        topLeftPattern.font = UIFont.systemFont(ofSize: miniSize)
        topLeftPattern.textColor = UIColor.white.withAlphaComponent(0.5)
        topLeftPattern.frame = CGRect(x: margin, y: margin, width: miniSize, height: miniSize)
        backView.addSubview(topLeftPattern)
        
        // Sağ üst
        let topRightPattern = UILabel()
        topRightPattern.text = theme.pattern
        topRightPattern.textAlignment = .center
        topRightPattern.font = UIFont.systemFont(ofSize: miniSize)
        topRightPattern.textColor = UIColor.white.withAlphaComponent(0.5)
        topRightPattern.frame = CGRect(x: bounds.width - miniSize - margin, y: margin, width: miniSize, height: miniSize)
        backView.addSubview(topRightPattern)
        
        // Sol alt
        let bottomLeftPattern = UILabel()
        bottomLeftPattern.text = theme.pattern
        bottomLeftPattern.textAlignment = .center
        bottomLeftPattern.font = UIFont.systemFont(ofSize: miniSize)
        bottomLeftPattern.textColor = UIColor.white.withAlphaComponent(0.5)
        bottomLeftPattern.frame = CGRect(x: margin, y: bounds.height - miniSize - margin, width: miniSize, height: miniSize)
        backView.addSubview(bottomLeftPattern)
        
        // Sağ alt
        let bottomRightPattern = UILabel()
        bottomRightPattern.text = theme.pattern
        bottomRightPattern.textAlignment = .center
        bottomRightPattern.font = UIFont.systemFont(ofSize: miniSize)
        bottomRightPattern.textColor = UIColor.white.withAlphaComponent(0.5)
        bottomRightPattern.frame = CGRect(x: bounds.width - miniSize - margin, y: bounds.height - miniSize - margin, width: miniSize, height: miniSize)
        backView.addSubview(bottomRightPattern)
    }
    
    private func createValueLabel(position: CardCorner, color: UIColor) -> UILabel {
        let label = UILabel()
        let isTopLeft = position == .topLeft
        
        // Profesyonel görünüm için kartın boyutuna göre ayarla
        let labelWidth = bounds.width * 0.28
        let labelHeight = bounds.height * 0.22
        let margin = bounds.width * 0.05
        
        // Simge ve değeri üst üste değil yan yana yerleştir
        if isTopLeft {
            label.frame = CGRect(x: margin, y: margin, width: labelWidth, height: labelHeight)
            label.text = value
            
            // Simgeyi ayrı ekle
            let suitLabel = UILabel()
            suitLabel.text = suit
            suitLabel.textColor = color
            suitLabel.font = UIFont.systemFont(ofSize: labelHeight * 0.7, weight: .medium)
            suitLabel.frame = CGRect(x: margin + labelWidth, y: margin, width: labelHeight, height: labelHeight)
            suitLabel.textAlignment = .center
            frontView.addSubview(suitLabel)
        } else {
            label.frame = CGRect(
                x: bounds.width - labelWidth - margin - labelHeight,
                y: bounds.height - labelHeight - margin,
                width: labelWidth,
                height: labelHeight
            )
            label.text = value
            label.transform = CGAffineTransform(rotationAngle: .pi)
            
            // Simgeyi ayrı ekle
            let suitLabel = UILabel()
            suitLabel.text = suit
            suitLabel.textColor = color
            suitLabel.font = UIFont.systemFont(ofSize: labelHeight * 0.7, weight: .medium)
            suitLabel.frame = CGRect(
                x: bounds.width - labelHeight - margin, 
                y: bounds.height - labelHeight - margin, 
                width: labelHeight, 
                height: labelHeight
            )
            suitLabel.textAlignment = .center
            suitLabel.transform = CGAffineTransform(rotationAngle: .pi)
            frontView.addSubview(suitLabel)
        }
        
        // Optimize edilmiş boyut ve stil
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: labelHeight * 0.65, weight: .bold)
        label.textAlignment = .center
        
        return label
    }
    
    // MARK: - Card Functions
    
    func flip() {
        isRevealed = !isRevealed
        
        UIView.transition(
            with: self,
            duration: GameConfig.flipAnimationDuration,
            options: .transitionFlipFromLeft,
            animations: {
                self.updateCardFace()
            },
            completion: nil
        )
        
        // Provide haptic feedback when flipping
        if GameConfig.hapticFeedbackEnabled {
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred()
        }
    }
    
    private func updateCardFace() {
        frontView.isHidden = !isRevealed
        backView.isHidden = isRevealed
    }
    
    func updateTheme() {
        setupCardBackContent()
    }
    
    // MARK: - Value Calculations
    
    // Get face value as number (A=1, J=11, Q=12, K=13)
    var numericValue: Int {
        switch value {
        case "A": return 1
        case "J": return 11
        case "Q": return 12
        case "K": return 13
        default: return Int(value) ?? 0
        }
    }
    
    // Check if card can be stacked on top of another card
    func canStackOnTop(of card: Card) -> Bool {
        // Must be one less in value
        return self.numericValue == card.numericValue - 1
    }
    
    // Check if card sequence is valid (consecutive descending same suit)
    static func isValidSequence(cards: [Card]) -> Bool {
        guard cards.count > 1 else { return true }
        
        // All cards must be face up
        guard cards.allSatisfy({ $0.isRevealed }) else { return false }
        
        // All cards must be same suit
        let suit = cards[0].suit
        guard cards.allSatisfy({ $0.suit == suit }) else { return false }
        
        // Check consecutive descending values
        for i in 0..<cards.count-1 {
            if cards[i].numericValue != cards[i+1].numericValue + 1 {
                return false
            }
        }
        
        return true
    }
    
    // Check if cards form a complete sequence (K to A in same suit)
    static func isCompleteSequence(cards: [Card]) -> Bool {
        // En az 13 kart gerekiyor (K'dan A'ya)
        guard cards.count == 13 else { return false }
        
        // Tüm kartlar açıkta olmalı
        for card in cards {
            if !card.isRevealed {
                return false
            }
        }
        
        // İlk takımı standart olarak kabul edelim
        let firstSuit = cards[0].suit
        
        // Tüm kartlar aynı takımdan olmalı
        for card in cards {
            if card.suit != firstSuit {
                return false
            }
        }
        
        // K'dan A'ya kontrol
        let expectedValues = ["K", "Q", "J", "10", "9", "8", "7", "6", "5", "4", "3", "2", "A"]
        
        // Kartlar doğru sırada olmalı
        for i in 0..<13 {
            if cards[i].value != expectedValues[i] {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Highlight Effects
    
    func highlightAsHint() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.systemYellow.cgColor
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
                self.layer.borderWidth = 0.0
            }
        })
    }
    
    func highlightAsMovable() {
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.systemGreen.cgColor
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.layer.borderWidth = 0.0
            }
        })
    }
    
    // MARK: - Utility
    
    enum CardCorner {
        case topLeft
        case bottomRight
    }
    
    // Static yardımcı fonksiyonlar
    static func createFromCardState(cardState: GameConfig.CardState) -> Card {
        return Card(
            value: cardState.value,
            suit: cardState.suit,
            faceUp: cardState.isRevealed
        )
    }
    
    // [String: Any] dictionary'den Card oluşturmak için static yardımcı metod
    static func createFromDict(dict: [String: Any]) -> Card? {
        guard let value = dict["value"] as? String,
              let suit = dict["suit"] as? String,
              let isRevealed = dict["isRevealed"] as? Bool else {
            return nil
        }
        
        return Card(
            value: value,
            suit: suit,
            faceUp: isRevealed
        )
    }
    
    // Tuple'dan Card oluşturmak için static yardımcı metod
    static func createFromTuple(tuple: (value: String, suit: String, isRevealed: Bool)) -> Card {
        return Card(
            value: tuple.value,
            suit: tuple.suit,
            faceUp: tuple.isRevealed
        )
    }
} 