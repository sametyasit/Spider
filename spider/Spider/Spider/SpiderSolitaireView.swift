//
//  SpiderSolitaireView.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

class SpiderSolitaireView: UIView {
    
    // MARK: - Properties
    
    // UI elements
    private var stacks: [CardStack] = []
    private var stockPile: UIView!
    private var completedSets: UIView!
    private var toolbar: UIToolbar!
    
    // Game state
    private var deck: [Card] = []
    private var stockCards: [Card] = []
    private var completedSetCount: Int = 0
    private var moves: Int = 0
    private var score: Int = 500 // Starting score
    
    // Drag and drop
    private var draggingCard: Card?
    private var draggingCards: [Card]?
    private var dragOriginStack: CardStack?
    private var dragStartPosition: CGPoint = .zero
    private var dragOffset: CGPoint = .zero
    private var cardSnapshot: UIView?
    
    // Timer
    private var gameTimer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var timerLabel: UILabel!
    private var scoreLabel: UILabel!
    private var movesLabel: UILabel!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGame()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGame()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Recalculate layout when view size changes
        setupToolbar()
        setupStacks()
        setupStockPile()
        setupCompletedArea()
    }
    
    // MARK: - Setup
    
    private func setupGame() {
        backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0) // Green background
        
        setupToolbar()
        setupStacks()
        setupStockPile()
        setupCompletedArea()
        setupGestureRecognizers()
    }
    
    private func setupToolbar() {
        // Remove existing toolbar if any
        toolbar?.removeFromSuperview()
        
        // Create labels for game information
        timerLabel = createLabel(withText: "Süre: 00:00")
        scoreLabel = createLabel(withText: "Puan: 500")
        movesLabel = createLabel(withText: "Hamle: 0")
        
        // Create toolbar items
        let newGameButton = UIBarButtonItem(title: "Yeni Oyun", style: .plain, target: self, action: #selector(newGameTapped))
        let undoButton = UIBarButtonItem(title: "Geri Al", style: .plain, target: self, action: #selector(undoTapped))
        let hintButton = UIBarButtonItem(title: "İpucu", style: .plain, target: self, action: #selector(hintTapped))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let timerItem = UIBarButtonItem(customView: timerLabel)
        let scoreItem = UIBarButtonItem(customView: scoreLabel)
        let movesItem = UIBarButtonItem(customView: movesLabel)
        
        // Setup difficulty selector
        let segmentedControl = UISegmentedControl(items: ["1 Takım", "2 Takım", "4 Takım"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(difficultyChanged(_:)), for: .valueChanged)
        let difficultyItem = UIBarButtonItem(customView: segmentedControl)
        
        // For portrait mode, use a more compact toolbar
        let toolbarHeight: CGFloat = 44
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: toolbarHeight))
        
        // For portrait mode, we'll use a simpler set of items
        toolbar.items = [
            newGameButton, flexSpace,
            difficultyItem, flexSpace,
            timerItem
        ]
        
        // Add a second toolbar for score and moves
        let secondToolbar = UIToolbar(frame: CGRect(x: 0, y: toolbarHeight, width: bounds.width, height: toolbarHeight))
        secondToolbar.items = [
            scoreItem, flexSpace,
            movesItem, flexSpace,
            undoButton, flexSpace,
            hintButton
        ]
        
        addSubview(toolbar)
        addSubview(secondToolbar)
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.sizeToFit()
        return label
    }
    
    private func setupStacks() {
        // Remove existing stacks if any
        stacks.forEach { $0.removeFromSuperview() }
        stacks.removeAll()
        
        // Calculate layout for portrait mode
        let stackWidth = GameConfig.cardWidth
        let stacksPerRow = 5 // Display 5 stacks per row
        let stackSpacing = GameConfig.stackSpacing
        
        // Calculate the total width of stacks in a row
        let totalRowWidth = CGFloat(stacksPerRow) * stackWidth + CGFloat(stacksPerRow - 1) * stackSpacing
        let startX = (bounds.width - totalRowWidth) / 2
        let startY = toolbar.frame.maxY + toolbar.frame.height + GameConfig.verticalMargin
        
        // Create new stacks in 2 rows
        for i in 0..<GameConfig.numberOfStacks {
            let row = i / stacksPerRow
            let col = i % stacksPerRow
            
            let x = startX + CGFloat(col) * (stackWidth + stackSpacing)
            let y = startY + CGFloat(row) * (GameConfig.cardHeight + GameConfig.verticalMargin)
            
            let stackFrame = CGRect(x: x, y: y, width: stackWidth, height: GameConfig.cardHeight)
            let stack = CardStack(stackIndex: i, frame: stackFrame)
            stacks.append(stack)
            addSubview(stack)
        }
    }
    
    private func setupStockPile() {
        // Remove existing stock pile if any
        stockPile?.removeFromSuperview()
        
        // Create new stock pile at the bottom left
        let margin = GameConfig.horizontalMargin
        let width = GameConfig.cardWidth
        let height = GameConfig.cardHeight
        let y = bounds.height - height - margin
        
        stockPile = UIView(frame: CGRect(x: margin, y: y, width: width, height: height))
        stockPile.backgroundColor = .clear
        stockPile.layer.borderWidth = 1.0
        stockPile.layer.borderColor = UIColor.white.cgColor
        stockPile.layer.cornerRadius = 8.0
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stockPileTapped))
        stockPile.addGestureRecognizer(tapGesture)
        
        addSubview(stockPile)
    }
    
    private func setupCompletedArea() {
        // Remove existing completed area if any
        completedSets?.removeFromSuperview()
        
        // Create new completed sets area at the bottom right
        let margin = GameConfig.horizontalMargin
        let width = GameConfig.cardWidth * 2 + GameConfig.stackSpacing // Space for 2 completed stacks per row
        let height = GameConfig.cardHeight * 2 + GameConfig.verticalMargin // 2 rows for completed stacks
        let x = bounds.width - width - margin
        let y = bounds.height - height - margin
        
        completedSets = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        completedSets.backgroundColor = .clear
        
        addSubview(completedSets)
    }
    
    private func setupGestureRecognizers() {
        // Add pan gesture recognizer for card dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    // MARK: - Game Logic
    
    func startNewGame() {
        // Reset game state
        resetGame()
        
        // Create and shuffle a deck based on difficulty
        createDeck()
        
        // Deal initial cards
        dealInitialCards()
        
        // Start timer
        startTimer()
    }
    
    private func resetGame() {
        // Reset game variables
        completedSetCount = 0
        moves = 0
        score = 500
        elapsedTime = 0
        
        // Stop timer if running
        gameTimer?.invalidate()
        gameTimer = nil
        
        // Clear stacks
        for stack in stacks {
            for card in stack.cards {
                card.removeFromSuperview()
            }
            stack.cards.removeAll()
        }
        
        // Clear stock pile
        stockCards.removeAll()
        for subview in stockPile.subviews {
            subview.removeFromSuperview()
        }
        
        // Clear completed sets
        for subview in completedSets.subviews {
            subview.removeFromSuperview()
        }
        
        // Update UI
        updateLabels()
    }
    
    private func createDeck() {
        deck.removeAll()
        
        // Determine number of decks and suits based on difficulty
        let numSuits: Int
        switch GameConfig.difficultyLevel {
        case .easy:
            numSuits = 1 // Only spades
        case .medium:
            numSuits = 2 // Spades and hearts
        case .hard:
            numSuits = 4 // All suits
        }
        
        // For Spider Solitaire, we use two decks (104 cards)
        for _ in 0..<2 {
            for i in 0..<numSuits {
                let suitIndex = i % GameConfig.cardSuits.count
                let suit = GameConfig.cardSuits[suitIndex]
                
                for value in GameConfig.cardValues {
                    let card = Card(value: value, suit: suit)
                    deck.append(card)
                }
            }
        }
        
        // Shuffle the deck
        deck.shuffle()
    }
    
    private func dealInitialCards() {
        // Deal initial cards to the 10 tableaus
        // 54 cards in total: 5 face-down cards + 1 face-up card for stacks 0-3
        // 4 face-down cards + 1 face-up card for stacks 4-9
        
        for stackIndex in 0..<GameConfig.numberOfStacks {
            let cardsInStack = (stackIndex < 4) ? 6 : 5
            
            for cardIndex in 0..<cardsInStack {
                if let card = deck.popLast() {
                    // Only the top card should be face up
                    card.isRevealed = (cardIndex == cardsInStack - 1)
                    
                    // Add to appropriate stack
                    stacks[stackIndex].addCard(card)
                }
            }
        }
        
        // Remaining cards go to stock
        stockCards = deck
        updateStockPileUI()
    }
    
    private func updateStockPileUI() {
        // Clear existing cards
        for subview in stockPile.subviews {
            subview.removeFromSuperview()
        }
        
        // If there are cards in stock, show stacked cards
        if !stockCards.isEmpty {
            // Calculate number of "stacks" to show (1 for each 10 cards)
            let numberOfStacks = (stockCards.count + 9) / 10 // Round up division
            
            for i in 0..<numberOfStacks {
                let cardBack = UIView(frame: CGRect(
                    x: CGFloat(i) * 2.0,
                    y: CGFloat(i) * 2.0,
                    width: GameConfig.cardWidth,
                    height: GameConfig.cardHeight
                ))
                cardBack.backgroundColor = .blue
                cardBack.layer.cornerRadius = 8.0
                
                // Add card decoration
                let innerView = UIView(frame: CGRect(
                    x: 10, y: 10,
                    width: cardBack.bounds.width - 20,
                    height: cardBack.bounds.height - 20
                ))
                innerView.backgroundColor = .white
                innerView.layer.cornerRadius = 5.0
                cardBack.addSubview(innerView)
                
                // Add spider logo
                let logo = UILabel(frame: innerView.bounds)
                logo.text = "🕸️"
                logo.textAlignment = .center
                logo.font = UIFont.systemFont(ofSize: 30)
                innerView.addSubview(logo)
                
                stockPile.addSubview(cardBack)
            }
        }
    }
    
    @objc private func stockPileTapped() {
        // Check if there are cards left in stock
        guard !stockCards.isEmpty else {
            // Show alert when no more cards in stock
            showAlert(title: "Kart Kalmadı", message: "Dağıtılacak başka kart kalmadı.")
            return
        }
        
        // Check if all stacks have at least one card
        for stack in stacks {
            if stack.cards.isEmpty {
                showAlert(title: "Boş Sütun", message: "Yeni kartlar dağıtmak için tüm sütunlarda en az bir kart olmalıdır.")
                return
            }
        }
        
        // Deal one card to each stack
        dealMoreCards()
        moves += 1
        score -= 1 // Penalty for dealing more cards
        updateLabels()
    }
    
    private func dealMoreCards() {
        // Deal one card to each stack, face up
        for stackIndex in 0..<GameConfig.numberOfStacks {
            if let card = stockCards.popLast() {
                card.isRevealed = true
                stacks[stackIndex].addCard(card, animated: true)
            }
        }
        
        // Update stock pile UI
        updateStockPileUI()
    }
    
    private func startTimer() {
        // Reset elapsed time
        elapsedTime = 0
        updateLabels()
        
        // Start the timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            self.updateLabels()
        }
    }
    
    private func updateLabels() {
        // Format time as MM:SS
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "Süre: %02d:%02d", minutes, seconds)
        
        // Update score and moves
        scoreLabel.text = "Puan: \(score)"
        movesLabel.text = "Hamle: \(moves)"
        
        // Resize labels
        timerLabel.sizeToFit()
        scoreLabel.sizeToFit()
        movesLabel.sizeToFit()
    }
    
    private func checkForCompletedSets() {
        // Check each stack for completed sets (K down to A of the same suit)
        for stack in stacks {
            for i in 0..<stack.cards.count {
                if stack.isCompletedSet(fromIndex: i) {
                    // We found a completed set, remove it from the stack
                    let completedCards = Array(stack.cards.suffix(from: i))
                    for card in completedCards {
                        _ = stack.removeCard(card)
                    }
                    
                    // Add to completed area
                    addCompletedSet(completedCards)
                    
                    // Update game state
                    completedSetCount += 1
                    score += 100 // Bonus for completing a set
                    
                    // Check for game win
                    if completedSetCount >= 8 { // 8 completed sets means the game is won
                        gameWon()
                    }
                    
                    // Update UI
                    updateLabels()
                    
                    // Since we modified the stack, we need to restart the check
                    return checkForCompletedSets()
                }
            }
        }
    }
    
    private func addCompletedSet(_ cards: [Card]) {
        // Add animation to show completed set
        let startFrame = CGRect(
            x: bounds.width / 2 - GameConfig.cardWidth / 2,
            y: bounds.height / 2 - GameConfig.cardHeight / 2,
            width: GameConfig.cardWidth,
            height: GameConfig.cardHeight
        )
        
        // Calculate position in completed area for portrait mode
        // We'll use a 2x4 grid for completed sets
        let setIndex = completedSetCount
        let row = setIndex / 2
        let col = setIndex % 2
        
        let setFrame = CGRect(
            x: CGFloat(col) * (GameConfig.cardWidth + GameConfig.stackSpacing),
            y: CGFloat(row) * (GameConfig.cardHeight + GameConfig.verticalMargin),
            width: GameConfig.cardWidth,
            height: GameConfig.cardHeight
        )
        
        // Create a card to represent the completed set
        let kingCard = cards.first! // The king card (top of set)
        let completedCard = Card(value: kingCard.value, suit: kingCard.suit, faceUp: true)
        completedCard.frame = startFrame
        completedCard.alpha = 0
        completedSets.addSubview(completedCard)
        
        // Animate the card to the completed area
        UIView.animate(withDuration: 0.5, animations: {
            completedCard.frame = setFrame
            completedCard.alpha = 1
        })
    }
    
    private func gameWon() {
        // Stop timer
        gameTimer?.invalidate()
        
        // Calculate bonus based on time and moves
        let timeBonus = max(0, 1000 - Int(elapsedTime))
        let moveBonus = max(0, 500 - moves * 2)
        let finalScore = score + timeBonus + moveBonus
        
        // Show win message
        showAlert(title: "Tebrikler!", 
                  message: "Oyunu kazandınız!\nSüre: \(formatTime(elapsedTime))\nHamle: \(moves)\nPuan: \(finalScore)")
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func showAlert(title: String, message: String) {
        if let viewController = findViewController() {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            viewController.present(alert, animated: true)
        }
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    // MARK: - Actions
    
    @objc private func newGameTapped() {
        startNewGame()
    }
    
    @objc private func undoTapped() {
        // Implement undo functionality
        showAlert(title: "Bilgi", message: "Geri alma özelliği şu anda mevcut değil.")
    }
    
    @objc private func hintTapped() {
        // Implement hint functionality
        showAlert(title: "Bilgi", message: "İpucu özelliği şu anda mevcut değil.")
    }
    
    @objc private func difficultyChanged(_ sender: UISegmentedControl) {
        // Change difficulty based on selection
        switch sender.selectedSegmentIndex {
        case 0:
            GameConfig.difficultyLevel = .easy
        case 1:
            GameConfig.difficultyLevel = .medium
        case 2:
            GameConfig.difficultyLevel = .hard
        default:
            GameConfig.difficultyLevel = .easy
        }
        
        // Start a new game with the selected difficulty
        startNewGame()
    }
    
    // MARK: - Card Dragging
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            beginDragging(at: location)
            
        case .changed:
            if draggingCards != nil {
                updateDragging(at: location)
            }
            
        case .ended, .cancelled:
            if draggingCards != nil {
                endDragging(at: location)
            }
            
        default:
            break
        }
    }
    
    private func beginDragging(at location: CGPoint) {
        // Find the card that was tapped
        for stack in stacks {
            if let card = stack.cardAt(point: location) {
                // Check if the card is part of a valid sequence
                if let cardsToMove = stack.cardsFromCard(card), Card.isValidSequence(cards: cardsToMove) {
                    // Start dragging these cards
                    draggingCards = cardsToMove
                    draggingCard = card
                    dragOriginStack = stack
                    
                    // Calculate drag offset
                    let cardFrame = card.convert(card.bounds, to: self)
                    dragOffset = CGPoint(x: location.x - cardFrame.minX, y: location.y - cardFrame.minY)
                    
                    // Create a snapshot of cards
                    createCardSnapshot(cardsToMove)
                    
                    // Remove cards from stack temporarily
                    _ = stack.removeCards(from: card)
                    
                    // Update UI
                    bringSubviewToFront(cardSnapshot!)
                    return
                }
            }
        }
    }
    
    private func createCardSnapshot(_ cards: [Card]) {
        // Create a view that looks like the stack of cards being dragged
        let snapHeight = GameConfig.cardOverlap * CGFloat(cards.count - 1) + GameConfig.cardHeight
        cardSnapshot = UIView(frame: CGRect(x: 0, y: 0, width: GameConfig.cardWidth, height: snapHeight))
        cardSnapshot?.backgroundColor = .clear
        
        // Add each card to the snapshot
        for (index, card) in cards.enumerated() {
            let cardCopy = Card(value: card.value, suit: card.suit, faceUp: true)
            cardCopy.frame.origin.y = CGFloat(index) * GameConfig.cardOverlap
            cardSnapshot?.addSubview(cardCopy)
        }
        
        addSubview(cardSnapshot!)
    }
    
    private func updateDragging(at location: CGPoint) {
        // Update position of the snapshot
        guard let snapshot = cardSnapshot else { return }
        
        let x = location.x - dragOffset.x
        let y = location.y - dragOffset.y
        snapshot.frame.origin = CGPoint(x: x, y: y)
    }
    
    private func endDragging(at location: CGPoint) {
        guard let cards = draggingCards, let snapshot = cardSnapshot, let originStack = dragOriginStack else { return }
        
        // Find stack under the drop location
        var targetStack: CardStack?
        
        for stack in stacks {
            let stackFrame = stack.convert(stack.bounds, to: self)
            if stackFrame.contains(location) {
                targetStack = stack
                break
            }
        }
        
        // Check if we can place the cards in the target stack
        if let targetStack = targetStack, targetStack.canAddCards(cards) {
            // Add the cards to the target stack
            targetStack.addCards(cards, animated: true)
            
            // Increment move count
            moves += 1
            
            // Check for completed sets
            checkForCompletedSets()
            
            // Update UI
            updateLabels()
        } else {
            // Return cards to original stack
            originStack.addCards(cards, animated: true)
        }
        
        // Clean up
        snapshot.removeFromSuperview()
        cardSnapshot = nil
        draggingCards = nil
        draggingCard = nil
        dragOriginStack = nil
    }
} 