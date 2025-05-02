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
        
        // Debug bilgisi
        print("Kart oluşturuldu: \(value) \(suit), faceUp: \(faceUp)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCard() {
        // Setup card appearance
        layer.cornerRadius = 12.0
        clipsToBounds = false
        
        // Add improved shadow for 3D effect
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.4
        
        // Setup front view (face up)
        frontView.frame = bounds
        frontView.backgroundColor = .white
        frontView.layer.cornerRadius = 12.0
        frontView.isHidden = !faceUp
        frontView.layer.borderWidth = 0.5
        frontView.layer.borderColor = UIColor.lightGray.cgColor
        frontView.clipsToBounds = true
        addSubview(frontView)
        setupCardFrontContent()
        
        // Setup back view (face down)
        backView.frame = bounds
        backView.layer.cornerRadius = 12.0
        backView.isHidden = faceUp
        backView.layer.borderWidth = 0.5
        backView.layer.borderColor = UIColor.lightGray.cgColor
        backView.clipsToBounds = true
        addSubview(backView)
        setupCardBackContent()
        
        // Set initial state
        isRevealed = faceUp
    }
    
    private func setupCardFrontContent() {
        // Clear previous content if any
        for subview in frontView.subviews {
            subview.removeFromSuperview()
        }
        frontValueLabels.removeAll()
        
        // Add a subtle gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frontView.bounds
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor(white: 0.95, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = frontView.layer.cornerRadius
        frontView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Get color for the suit
        let color = GameConfig.suitColors[suit] ?? .black
        
        // Top-left value and suit
        let topLabel = createValueLabel(position: .topLeft, color: color)
        frontView.addSubview(topLabel)
        frontValueLabels.append(topLabel)
        
        // Bottom-right value and suit (inverted)
        let bottomLabel = createValueLabel(position: .bottomRight, color: color)
        frontView.addSubview(bottomLabel)
        frontValueLabels.append(bottomLabel)
        
        // Center suit with larger size
        frontSuitLabel = UILabel()
        frontSuitLabel.text = suit
        frontSuitLabel.textColor = color
        frontSuitLabel.font = UIFont.systemFont(ofSize: 50, weight: .medium)
        frontSuitLabel.textAlignment = .center
        frontSuitLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        
        // Add shadow to center suit for more depth
        frontSuitLabel.layer.shadowColor = UIColor.black.cgColor
        frontSuitLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        frontSuitLabel.layer.shadowRadius = 1
        frontSuitLabel.layer.shadowOpacity = 0.3
        
        frontView.addSubview(frontSuitLabel)
        
        // Add decorative mini suits for face cards
        if ["J", "Q", "K"].contains(value) {
            addFaceCardDecorations(color: color)
        }
        
        // Debug bilgisi
        print("Kart ön yüzü oluşturuldu: \(value) \(suit)")
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
        
        // Set background color with gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backView.bounds
        gradientLayer.colors = [
            theme.cardBack.cgColor,
            theme.cardBack.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = backView.layer.cornerRadius
        backView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Create card back pattern with better design
        let patternView = UIView(frame: CGRect(x: 8, y: 8, width: bounds.width - 16, height: bounds.height - 16))
        patternView.backgroundColor = UIColor.clear
        patternView.layer.cornerRadius = 10.0
        patternView.layer.borderWidth = 3.0
        patternView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        backView.addSubview(patternView)
        
        // Add a second inner border for more design
        let innerBorder = UIView(frame: CGRect(x: 15, y: 15, width: bounds.width - 30, height: bounds.height - 30))
        innerBorder.backgroundColor = UIColor.clear
        innerBorder.layer.cornerRadius = 6.0
        innerBorder.layer.borderWidth = 1.0
        innerBorder.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backView.addSubview(innerBorder)
        
        // Add pattern to back
        backPattern = UILabel(frame: CGRect(x: 0, y: 0, width: backView.bounds.width, height: backView.bounds.height))
        backPattern.text = theme.pattern
        backPattern.textAlignment = .center
        backPattern.font = UIFont.systemFont(ofSize: 40)
        backPattern.textColor = .white
        
        // Add glow to pattern
        backPattern.layer.shadowColor = UIColor.white.cgColor
        backPattern.layer.shadowRadius = 3
        backPattern.layer.shadowOpacity = 0.5
        backPattern.layer.shadowOffset = .zero
        
        backView.addSubview(backPattern)
        
        // Add additional decorations
        let gridSize = 3
        let gridItemSize = patternView.bounds.width / CGFloat(gridSize)
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if (row + col) % 2 == 0 && !(row == gridSize/2 && col == gridSize/2) {
                    let miniPattern = UILabel()
                    miniPattern.text = theme.pattern
                    miniPattern.textAlignment = .center
                    miniPattern.font = UIFont.systemFont(ofSize: 12)
                    miniPattern.textColor = .white.withAlphaComponent(0.3)
                    miniPattern.frame = CGRect(
                        x: CGFloat(col) * gridItemSize,
                        y: CGFloat(row) * gridItemSize,
                        width: gridItemSize,
                        height: gridItemSize
                    )
                    patternView.addSubview(miniPattern)
                }
            }
        }
    }
    
    private func createValueLabel(position: CardCorner, color: UIColor) -> UILabel {
        let label = UILabel()
        let isTopLeft = position == .topLeft
        
        // Set label text with value and suit
        label.text = "\(value)\n\(suit)"
        label.textColor = color
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        
        // Position the label
        let labelWidth: CGFloat = 25
        let labelHeight: CGFloat = 30
        let margin: CGFloat = 5
        
        if isTopLeft {
            label.frame = CGRect(x: margin, y: margin, width: labelWidth, height: labelHeight)
        } else {
            label.frame = CGRect(
                x: bounds.width - labelWidth - margin,
                y: bounds.height - labelHeight - margin,
                width: labelWidth,
                height: labelHeight
            )
            // Rotate 180 degrees for bottom right
            label.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
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
        
        // Debug bilgisi
        print("Kart yüzü güncellendi: \(value) \(suit), isRevealed: \(isRevealed)")
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
        guard cards.count == 13 else { return false }
        
        // Check if sequence is valid
        guard isValidSequence(cards: cards) else { return false }
        
        // Check if sequence starts with K and ends with A
        return cards.first?.value == "K" && cards.last?.value == "A"
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
} 