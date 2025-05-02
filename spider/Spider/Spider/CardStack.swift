//
//  CardStack.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

class CardStack: UIView {
    
    // MARK: - Properties
    
    var cards: [Card] = []
    var stackIndex: Int
    
    // Visual indicator for empty stacks
    private var emptyIndicator: UIView!
    
    // Animation properties
    private var completedSequenceContainer: UIView?
    
    // MARK: - Initialization
    
    init(stackIndex: Int, frame: CGRect) {
        self.stackIndex = stackIndex
        super.init(frame: frame)
        setupStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupStack() {
        backgroundColor = .clear
        
        // Add a visual indicator for empty stacks
        setupEmptyIndicator()
    }
    
    private func setupEmptyIndicator() {
        emptyIndicator = UIView(frame: CGRect(x: 0, y: 0, width: GameConfig.cardWidth, height: GameConfig.cardHeight))
        emptyIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        emptyIndicator.layer.cornerRadius = 12.0
        
        // Create dashed border with a shape layer instead
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
        borderLayer.lineDashPattern = [NSNumber(value: 5), NSNumber(value: 5)]
        borderLayer.lineWidth = 2.0
        borderLayer.frame = emptyIndicator.bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: emptyIndicator.bounds, cornerRadius: 12.0).cgPath
        emptyIndicator.layer.addSublayer(borderLayer)
        
        // Add placeholder text
        let placeholderLabel = UILabel(frame: emptyIndicator.bounds)
        placeholderLabel.text = "+"
        placeholderLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = UIFont.systemFont(ofSize: 35, weight: .light)
        emptyIndicator.addSubview(placeholderLabel)
        
        // Add subtle pulsating animation
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 0.6
        pulseAnimation.toValue = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.infinity
        placeholderLabel.layer.add(pulseAnimation, forKey: "pulse")
        
        addSubview(emptyIndicator)
        emptyIndicator.isHidden = true
    }
    
    // MARK: - Card Management
    
    func addCard(_ card: Card) {
        cards.append(card)
        repositionCards()
    }
    
    func addCard(_ card: Card, animated: Bool) {
        cards.append(card)
        
        if animated {
            // Start card from a higher position for animation
            let originalFrame = card.frame
            card.frame.origin.y = -card.frame.size.height
            addSubview(card)
            
            // Animate to correct position
            UIView.animate(withDuration: GameConfig.dealAnimationDuration) {
                card.frame = originalFrame
            } completion: { _ in
                self.repositionCards()
            }
        } else {
            repositionCards()
        }
    }
    
    func addCards(_ newCards: [Card]) {
        cards.append(contentsOf: newCards)
        repositionCards()
    }
    
    func addCards(_ newCards: [Card], animated: Bool) {
        cards.append(contentsOf: newCards)
        
        if animated {
            // Animate cards into place
            for (index, card) in newCards.enumerated() {
                // Add with slight delay between cards
                let delay = Double(index) * 0.05
                
                // Set initial position
                let targetY = CGFloat(cards.count - newCards.count + index) * GameConfig.cardOverlap
                card.frame.origin.y = targetY - 20
                addSubview(card)
                
                // Animate to final position
                UIView.animate(withDuration: GameConfig.moveAnimationDuration, delay: delay, options: .curveEaseOut) {
                    card.frame.origin.y = targetY
                }
            }
            
            // Final repositioning after all animations
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(newCards.count) * 0.05 + GameConfig.moveAnimationDuration) {
                self.repositionCards()
            }
        } else {
            repositionCards()
        }
    }
    
    func removeCard(_ card: Card) {
        if let index = cards.firstIndex(of: card) {
            cards.remove(at: index)
            card.removeFromSuperview()
            repositionCards()
        }
    }
    
    func removeCards(from startIndex: Int) -> [Card] {
        let removedCards = Array(cards[startIndex...])
        cards.removeSubrange(startIndex...)
        repositionCards()
        return removedCards
    }
    
    func repositionCards() {
        // Show or hide empty indicator
        emptyIndicator.isHidden = !cards.isEmpty
        
        for (index, card) in cards.enumerated() {
            // Calculate position
            let yOffset = index > 0 ? CGFloat(index) * GameConfig.cardOverlap : 0
            let targetFrame = CGRect(
                x: 0,
                y: yOffset,
                width: card.frame.width,
                height: card.frame.height
            )
            
            // Add card if not already added
            if card.superview != self {
                card.frame = targetFrame
                addSubview(card)
            } else {
                // Animate to new position if already on the stack
                UIView.animate(withDuration: GameConfig.moveAnimationDuration) {
                    card.frame = targetFrame
                }
            }
            
            // Bring to front in proper order
            bringSubviewToFront(card)
        }
    }
    
    // MARK: - Game Logic
    
    // Check if a card can be added to this stack
    func canAcceptCard(_ card: Card) -> Bool {
        if cards.isEmpty {
            return true // Empty stacks can accept any card
        }
        
        if let topCard = cards.last {
            // Can only stack on matching suit if top card is revealed
            if topCard.isRevealed {
                return card.canStackOnTop(of: topCard)
            }
        }
        
        return false
    }
    
    // Check if a sequence of cards can be added to this stack
    func canAcceptCards(_ cardsToAdd: [Card]) -> Bool {
        guard !cardsToAdd.isEmpty else { return false }
        
        // If stack is empty, any sequence is valid
        if cards.isEmpty {
            return true
        }
        
        // Check if first card in sequence can be added to top card
        if let topCard = cards.last {
            if topCard.isRevealed {
                return cardsToAdd.first!.canStackOnTop(of: topCard)
            }
        }
        
        return false
    }
    
    // Get all sequences of cards that can be moved
    func getMovableSequences() -> [[Card]] {
        guard !cards.isEmpty else { return [] }
        
        var sequences: [[Card]] = []
        
        // All revealed cards can be moved individually
        for i in 0..<cards.count {
            if cards[i].isRevealed {
                // Check for valid sequences starting from this card
                var currentSequence = [cards[i]]
                
                // Add subsequent cards if they form a valid sequence
                for j in i+1..<cards.count {
                    currentSequence.append(cards[j])
                    
                    // Check if this is a valid sequence
                    if Card.isValidSequence(cards: currentSequence) {
                        sequences.append(currentSequence)
                    }
                }
            }
        }
        
        return sequences
    }
    
    // Check for and handle completed sequences (K to A of same suit)
    func checkForCompletedSequences() -> Bool {
        guard cards.count >= 13 else { return false }
        
        // Start checking from the end of the stack
        var index = cards.count - 13
        while index >= 0 {
            let potentialSequence = Array(cards[index..<index+13])
            
            // Check if this is a complete sequence
            if Card.isCompleteSequence(cards: potentialSequence) {
                // Animate and remove the sequence
                animateCompletedSequence(startIndex: index)
                return true
            }
            
            index -= 1
        }
        
        return false
    }
    
    // MARK: - Animations
    
    // Animate a completed sequence and remove it
    private func animateCompletedSequence(startIndex: Int) {
        let sequenceCards = Array(cards[startIndex..<startIndex+13])
        
        // Create a container for the animation
        completedSequenceContainer = UIView(frame: CGRect(
            x: 0,
            y: CGFloat(startIndex) * GameConfig.cardOverlap,
            width: GameConfig.cardWidth,
            height: GameConfig.cardHeight + GameConfig.cardOverlap * 12
        ))
        addSubview(completedSequenceContainer!)
        
        // Add cards to the container
        for (i, card) in sequenceCards.enumerated() {
            let cardCopy = Card(value: card.value, suit: card.suit, faceUp: true)
            cardCopy.isRevealed = true
            cardCopy.frame = CGRect(
                x: 0,
                y: CGFloat(i) * GameConfig.cardOverlap,
                width: GameConfig.cardWidth,
                height: GameConfig.cardHeight
            )
            completedSequenceContainer!.addSubview(cardCopy)
        }
        
        // Remove the actual cards from the stack
        cards.removeSubrange(startIndex..<startIndex+13)
        
        // If the stack is not empty and the new top card is not revealed, flip it
        if startIndex < cards.count && !cards[startIndex].isRevealed {
            cards[startIndex].flip()
        }
        
        // Repositions the remaining cards
        repositionCards()
        
        // Animate the sequence floating away and fading out
        UIView.animate(withDuration: GameConfig.completeAnimationDuration, delay: 0.2, options: .curveEaseInOut, animations: {
            self.completedSequenceContainer?.transform = CGAffineTransform(translationX: 0, y: -100)
            self.completedSequenceContainer?.alpha = 0
        }, completion: { _ in
            self.completedSequenceContainer?.removeFromSuperview()
            self.completedSequenceContainer = nil
            
            // Add sparkle effect
            self.addSparkleEffect()
        })
        
        // Provide haptic feedback for completion
        if GameConfig.hapticFeedbackEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }
    
    private func addSparkleEffect() {
        let emojis = ["✨", "🎉", "🌟", "💫", "⭐️"]
        
        for _ in 0..<15 {
            let sparkle = UILabel()
            sparkle.text = emojis.randomElement()
            sparkle.font = UIFont.systemFont(ofSize: CGFloat.random(in: 15...25))
            sparkle.textAlignment = .center
            sparkle.frame = CGRect(
                x: CGFloat.random(in: -20...GameConfig.cardWidth+20),
                y: CGFloat.random(in: -20...50),
                width: 30,
                height: 30
            )
            addSubview(sparkle)
            
            // Random animation
            let destinationY = CGFloat.random(in: -100...(-50))
            let destinationX = CGFloat.random(in: -50...50)
            let duration = TimeInterval.random(in: 0.5...1.5)
            let delay = TimeInterval.random(in: 0...0.3)
            
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
                sparkle.transform = CGAffineTransform(translationX: destinationX, y: destinationY)
                    .rotated(by: CGFloat.random(in: -0.5...0.5))
                sparkle.alpha = 0
            }, completion: { _ in
                sparkle.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Utilities
    
    // Get the total height of the stack (for scrolling calculations)
    var totalHeight: CGFloat {
        if cards.isEmpty {
            return GameConfig.cardHeight
        } else {
            return GameConfig.cardHeight + CGFloat(cards.count - 1) * GameConfig.cardOverlap
        }
    }
    
    // Find the card at a specific point
    func cardAt(point: CGPoint) -> Card? {
        for card in cards.reversed() {
            if card.frame.contains(point) {
                return card
            }
        }
        return nil
    }
    
    // Find the index of a card in the stack
    func indexOf(card: Card) -> Int? {
        return cards.firstIndex(of: card)
    }
    
    // Get all cards from a specific card to the end of the stack
    func cardsFromCard(_ card: Card) -> [Card]? {
        if let index = cards.firstIndex(of: card) {
            return Array(cards[index...])
        }
        return nil
    }
    
    // Check if cards starting from index form a completed set (K down to A of the same suit)
    func isCompletedSet(fromIndex index: Int) -> Bool {
        // Need 13 cards for a complete set
        guard index + 12 < cards.count else { return false }
        
        let potentialSet = Array(cards[index...index+12])
        return Card.isCompleteSequence(cards: potentialSet)
    }
} 