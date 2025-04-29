//
//  Card.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

class Card: UIView {
    
    // MARK: - Properties
    
    let value: String
    let suit: String
    let faceUp: Bool
    
    private let frontView = UIView()
    private let backView = UIView()
    
    var isRevealed: Bool = false {
        didSet {
            updateCardFace()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            layer.borderWidth = isSelected ? 2.0 : 0.0
            layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        }
    }
    
    var isDraggable: Bool = false
    
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
        // Setup card appearance
        layer.cornerRadius = 8.0
        clipsToBounds = true
        
        // Setup front view (face up)
        frontView.frame = bounds
        frontView.backgroundColor = .white
        frontView.layer.cornerRadius = 8.0
        frontView.isHidden = !faceUp
        addSubview(frontView)
        setupCardFrontContent()
        
        // Setup back view (face down)
        backView.frame = bounds
        backView.backgroundColor = .blue
        backView.layer.cornerRadius = 8.0
        backView.isHidden = faceUp
        addSubview(backView)
        setupCardBackContent()
        
        // Set initial state
        isRevealed = faceUp
    }
    
    private func setupCardFrontContent() {
        // Get color for the suit
        let color = GameConfig.suitColors[suit] ?? .black
        
        // Top-left value and suit
        let topLabel = createValueLabel(position: .topLeft, color: color)
        frontView.addSubview(topLabel)
        
        // Bottom-right value and suit (inverted)
        let bottomLabel = createValueLabel(position: .bottomRight, color: color)
        frontView.addSubview(bottomLabel)
        
        // Center suit with larger size
        let centerLabel = UILabel()
        centerLabel.text = suit
        centerLabel.textColor = color
        centerLabel.font = UIFont.systemFont(ofSize: 40)
        centerLabel.textAlignment = .center
        centerLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        frontView.addSubview(centerLabel)
    }
    
    private func setupCardBackContent() {
        // Create card back pattern
        let patternView = UIView(frame: CGRect(x: 10, y: 10, width: bounds.width - 20, height: bounds.height - 20))
        patternView.backgroundColor = .white
        patternView.layer.cornerRadius = 5.0
        backView.addSubview(patternView)
        
        // Add spider logo to back
        let logoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: patternView.bounds.width, height: patternView.bounds.height))
        logoLabel.text = "🕸️"
        logoLabel.textAlignment = .center
        logoLabel.font = UIFont.systemFont(ofSize: 30)
        patternView.addSubview(logoLabel)
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
            label.frame = CGRect(x: bounds.width - labelWidth - margin, 
                                y: bounds.height - labelHeight - margin, 
                                width: labelWidth, height: labelHeight)
            // Rotate 180 degrees for bottom right
            label.transform = CGAffineTransform(rotationAngle: .pi)
        }
        
        return label
    }
    
    // MARK: - Card Functions
    
    func flip() {
        isRevealed = !isRevealed
        
        UIView.transition(with: self, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            self.updateCardFace()
        }, completion: nil)
    }
    
    private func updateCardFace() {
        frontView.isHidden = !isRevealed
        backView.isHidden = isRevealed
    }
    
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
    
    // MARK: - Utility
    
    enum CardCorner {
        case topLeft
        case bottomRight
    }
} 