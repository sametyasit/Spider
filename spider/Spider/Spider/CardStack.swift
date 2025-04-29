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
    private let stackIndex: Int
    
    // Layout
    private let overlap: CGFloat = GameConfig.cardOverlap
    
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
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 8.0
    }
    
    // MARK: - Card Management
    
    func addCard(_ card: Card, animated: Bool = false) {
        cards.append(card)
        addSubview(card)
        layoutStack(animated: animated)
    }
    
    func addCards(_ newCards: [Card], animated: Bool = false) {
        for card in newCards {
            cards.append(card)
            addSubview(card)
        }
        layoutStack(animated: animated)
    }
    
    func removeCard(_ card: Card) -> Card? {
        guard let index = cards.firstIndex(of: card) else { return nil }
        let removedCard = cards.remove(at: index)
        removedCard.removeFromSuperview()
        layoutStack(animated: true)
        return removedCard
    }
    
    func removeCards(from card: Card) -> [Card]? {
        guard let index = cards.firstIndex(of: card) else { return nil }
        let removedCards = Array(cards.suffix(from: index))
        cards = Array(cards.prefix(upTo: index))
        
        for card in removedCards {
            card.removeFromSuperview()
        }
        
        layoutStack(animated: true)
        return removedCards
    }
    
    // MARK: - Card Checking
    
    func canAddCard(_ card: Card) -> Bool {
        if cards.isEmpty {
            // Any card can be added to an empty stack
            return true
        } else if let topCard = cards.last {
            // For non-empty stacks, the card must be one less in value and same suit
            return card.canStackOnTop(of: topCard)
        }
        return false
    }
    
    func canAddCards(_ cardsToAdd: [Card]) -> Bool {
        guard !cardsToAdd.isEmpty else { return false }
        
        // First card must be able to stack on our top card
        if cards.isEmpty {
            return true
        } else if let topCard = cards.last {
            return cardsToAdd.first!.canStackOnTop(of: topCard)
        }
        
        return false
    }
    
    func isCompletedSet(fromIndex index: Int) -> Bool {
        // Check if we have a sequence of K down to A all of the same suit
        guard index < cards.count else { return false }
        
        let sequence = Array(cards.suffix(from: index))
        
        // Must have 13 cards
        guard sequence.count == 13 else { return false }
        
        // Top card must be a King
        guard sequence.first?.value == "K" else { return false }
        
        // Bottom card must be an Ace
        guard sequence.last?.value == "A" else { return false }
        
        // Check if all cards are same suit and form a sequence
        return Card.isValidSequence(cards: sequence)
    }
    
    // MARK: - Layout
    
    func layoutStack(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.positionCards()
            }
        } else {
            positionCards()
        }
    }
    
    private func positionCards() {
        // Position cards in stack with overlap
        for (index, card) in cards.enumerated() {
            let yPosition = CGFloat(index) * overlap
            card.frame.origin = CGPoint(x: 0, y: yPosition)
            
            // Bring most recent cards to front
            bringSubviewToFront(card)
            
            // Make top card draggable
            card.isDraggable = (index == cards.count - 1)
            
            // Check if this is the last card in the stack
            if index == cards.count - 1 {
                // Ensure the last card is revealed
                if !card.isRevealed {
                    card.isRevealed = true
                }
            }
        }
        
        // Update stack height to fit all cards
        let stackHeight = (cards.count > 0) 
            ? overlap * CGFloat(cards.count - 1) + GameConfig.cardHeight
            : GameConfig.cardHeight
        
        frame.size.height = stackHeight
    }
    
    // Get card at a specific position
    func cardAt(point: CGPoint) -> Card? {
        // Convert the point to our coordinate system
        let localPoint = convert(point, from: superview)
        
        // Check from top to bottom (reverse order) since top cards are visible
        for card in cards.reversed() {
            if card.frame.contains(localPoint) && card.isRevealed {
                return card
            }
        }
        
        return nil
    }
    
    // Get cards from a specific card to the end
    func cardsFromCard(_ card: Card) -> [Card]? {
        guard let index = cards.firstIndex(of: card) else { return nil }
        return Array(cards.suffix(from: index))
    }
} 