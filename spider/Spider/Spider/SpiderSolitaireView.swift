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
    private var seed: Int? // For deterministic deals (challenges)
    private var isChallenge: Bool = false
    private var currentChallenge: DailyChallenge?
    
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
    
    // Statistics and score labels
    private var statusLabels: [UILabel] = []
    private var timerLabel: UILabel!
    private var scoreLabel: UILabel!
    private var movesLabel: UILabel!
    
    // Game history for undo
    private struct GameMove {
        let cards: [Card]
        let sourceStack: Int
        let destinationStack: Int
        let didRevealCard: Bool
    }
    private var moveHistory: [GameMove] = []
    
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
        backgroundColor = getThemeBackgroundColor()
        
        setupToolbar()
        setupStacks()
        setupStockPile()
        setupCompletedArea()
        setupGestureRecognizers()
        
        // Show welcome if first launch
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            showWelcomeMessage()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            // Start a new game after welcome
            startNewGame()
        } else {
            // Check for saved game
            if GameManager.shared.hasSavedGame() {
                showContinueGamePrompt()
            } else {
                // Start a new game immediately
                startNewGame()
            }
        }
    }
    
    private func getThemeBackgroundColor() -> UIColor {
        let theme = GameConfig.themes[GameConfig.currentTheme] ?? GameConfig.themes["Klasik"]!
        return theme.background
    }
    
    private func showWelcomeMessage() {
        let welcomeView = UIView(frame: bounds)
        welcomeView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let container = UIView(frame: CGRect(x: 50, y: bounds.height/2 - 150, width: bounds.width - 100, height: 300))
        container.backgroundColor = UIColor.systemBackground
        container.layer.cornerRadius = 16
        welcomeView.addSubview(container)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: container.bounds.width - 40, height: 30))
        titleLabel.text = "Spider Solitaire'e Hoş Geldiniz!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 60, width: container.bounds.width - 40, height: 180))
        messageLabel.text = """
            Spider Solitaire, Papaz'dan As'a doğru sıralayarak kartları düzenlediğiniz klasik bir solitaire oyunudur.
            
            • Aynı takımdan oluşan tam bir seri tamamlandığında, kartlar tahtadan kaldırılır.
            • Farklı takımlardan kartlar da yerleştirilebilir, ancak tamamlanmış bir seri için aynı takımdan olmaları gerekir.
            • Tüm kartları sıralamanız halinde oyunu kazanırsınız!
            
            Günlük meydan okumaları denemek veya zorluk seviyesini değiştirmek için sağ üstteki ayarlar düğmesine dokunun.
            
            İyi eğlenceler!
        """
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        container.addSubview(messageLabel)
        
        let okButton = UIButton(type: .system)
        okButton.frame = CGRect(x: container.bounds.width/2 - 50, y: container.bounds.height - 50, width: 100, height: 40)
        okButton.setTitle("Başla", for: .normal)
        okButton.backgroundColor = UIColor.systemBlue
        okButton.setTitleColor(.white, for: .normal)
        okButton.layer.cornerRadius = 8
        okButton.addTarget(self, action: #selector(dismissWelcome), for: .touchUpInside)
        container.addSubview(okButton)
        
        addSubview(welcomeView)
        
        // Animate in
        container.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3) {
            container.transform = .identity
        }
    }
    
    @objc private func dismissWelcome(_ sender: UIButton) {
        if let welcomeView = sender.superview?.superview {
            UIView.animate(withDuration: 0.3, animations: {
                welcomeView.alpha = 0
            }, completion: { _ in
                welcomeView.removeFromSuperview()
            })
        }
    }
    
    private func setupToolbar() {
        // Remove existing toolbar elements
        for view in subviews where view is UIToolbar || view is UILabel {
            view.removeFromSuperview()
        }
        statusLabels.removeAll()
        
        // Initialize toolbar but don't show it (using labels and buttons instead)
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 44))
        toolbar.isHidden = true
        addSubview(toolbar)
        
        // Create labels for game information with modern style
        timerLabel = createStatusLabel(withText: "Süre: 00:00")
        scoreLabel = createStatusLabel(withText: "Puan: 500")
        movesLabel = createStatusLabel(withText: "Hamle: 0")
        
        statusLabels = [timerLabel, scoreLabel, movesLabel]
        
        // Position labels at the top
        let topPadding: CGFloat = 40
        let labelHeight: CGFloat = 30
        let labelSpacing: CGFloat = 20
        let totalWidth = bounds.width - 80
        
        // Layout labels horizontally
        for (index, label) in statusLabels.enumerated() {
            let labelWidth = totalWidth / CGFloat(statusLabels.count)
            label.frame = CGRect(
                x: 40 + CGFloat(index) * labelWidth,
                y: topPadding,
                width: labelWidth,
                height: labelHeight
            )
            
            // Show/hide based on settings
            if label == timerLabel {
                label.isHidden = !GameConfig.showTimer
            } else if label == scoreLabel {
                label.isHidden = !GameConfig.showScore
            }
            
            addSubview(label)
        }
        
        // Add buttons
        let buttonSize: CGFloat = 40
        let buttonMargin: CGFloat = 10
        
        // Undo button
        let undoButton = createGameButton(
            image: UIImage(systemName: "arrow.uturn.backward"),
            x: buttonMargin,
            y: topPadding - 5,
            action: #selector(undoMove)
        )
        addSubview(undoButton)
        
        // Deal button
        let dealButton = createGameButton(
            image: UIImage(systemName: "arrow.clockwise"),
            x: bounds.width - buttonSize - buttonMargin,
            y: topPadding - 5,
            action: #selector(dealCards)
        )
        addSubview(dealButton)
        
        // Hint button (in between toolbar labels)
        let hintButton = createGameButton(
            image: UIImage(systemName: "lightbulb.fill"),
            x: bounds.width / 2 - buttonSize / 2,
            y: topPadding + labelHeight + 5,
            action: #selector(showHint)
        )
        addSubview(hintButton)
        
        // Challenge label if playing a daily challenge
        if isChallenge, let challenge = currentChallenge {
            let challengeLabel = UILabel(frame: CGRect(x: 0, y: topPadding + labelHeight + 40, width: bounds.width, height: 30))
            challengeLabel.text = "Günlük Meydan Okuma: \(challenge.name)"
            challengeLabel.textAlignment = .center
            challengeLabel.textColor = .white
            challengeLabel.font = UIFont.boldSystemFont(ofSize: 14)
            challengeLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            addSubview(challengeLabel)
        }
    }
    
    private func createStatusLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 0, alpha: 0.5)
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        
        // Add subtle inner shadow
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 0.25
        label.layer.shadowRadius = 2
        label.layer.masksToBounds = false
        
        return label
    }
    
    private func createGameButton(image: UIImage?, x: CGFloat, y: CGFloat, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        
        // Create a template image with the correct size
        var buttonImage = image
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        if let originalImage = image {
            buttonImage = originalImage.withConfiguration(config)
        }
        
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0, alpha: 0.5)
        button.layer.cornerRadius = 22
        button.frame = CGRect(x: x, y: y, width: 44, height: 44)
        
        // Add shadow for depth
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.layer.masksToBounds = false
        
        // Add a subtle highlight for pressed state
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.alpha = 0.9
        }
        
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
    
    private func setupStacks() {
        // Remove existing stacks if any
        stacks.forEach { $0.removeFromSuperview() }
        stacks.removeAll()
        
        print("Kart yığınları kuruluyor...")
        
        // Calculate layout for portrait mode
        let stackWidth = GameConfig.cardWidth
        let stacksPerRow = 5 // Display 5 stacks per row
        let stackSpacing = GameConfig.stackSpacing
        
        // Calculate the total width of stacks in a row
        let totalRowWidth = CGFloat(stacksPerRow) * stackWidth + CGFloat(stacksPerRow - 1) * stackSpacing
        let startX = (bounds.width - totalRowWidth) / 2
        let startY = toolbar.frame.maxY + 40 // Daha yüksek başlangıç noktası
        
        print("Ekran boyutları: \(bounds.width) x \(bounds.height)")
        print("Yığın başlangıç pozisyonu: (\(startX), \(startY))")
        
        // Create new stacks in 2 rows
        for i in 0..<GameConfig.numberOfStacks {
            let row = i / stacksPerRow
            let col = i % stacksPerRow
            
            let x = startX + CGFloat(col) * (stackWidth + stackSpacing)
            let y = startY + CGFloat(row) * (GameConfig.cardHeight + GameConfig.verticalMargin)
            
            let stackFrame = CGRect(x: x, y: y, width: stackWidth, height: GameConfig.cardHeight)
            let stack = CardStack(stackIndex: i, frame: stackFrame)
            stack.layer.borderWidth = 1
            stack.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            stack.layer.cornerRadius = 8
            
            print("Yığın #\(i) oluşturuldu, pozisyon: \(stackFrame)")
            
            stacks.append(stack)
            addSubview(stack)
        }
        
        print("Toplam \(stacks.count) yığın kuruldu")
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
        stockPile.backgroundColor = UIColor(white: 0, alpha: 0.2)
        stockPile.layer.borderWidth = 2.0
        stockPile.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        stockPile.layer.cornerRadius = 12.0
        
        // Add visual indicator for stock pile
        let indicatorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        indicatorLabel.text = "🔄"
        indicatorLabel.font = UIFont.systemFont(ofSize: 24)
        indicatorLabel.textAlignment = .center
        indicatorLabel.alpha = 0.7
        stockPile.addSubview(indicatorLabel)
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stockPileTapped))
        stockPile.addGestureRecognizer(tapGesture)
        
        // Add shadow for depth
        stockPile.layer.shadowColor = UIColor.black.cgColor
        stockPile.layer.shadowOffset = CGSize(width: 0, height: 3)
        stockPile.layer.shadowRadius = 5
        stockPile.layer.shadowOpacity = 0.3
        stockPile.layer.masksToBounds = false
        
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
        completedSets.backgroundColor = UIColor(white: 0, alpha: 0.1)
        completedSets.layer.cornerRadius = 12.0
        
        // Add a label to indicate completed sets area
        let completedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 24))
        completedLabel.text = "Tamamlanan Seriler"
        completedLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        completedLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        completedLabel.textAlignment = .center
        completedSets.addSubview(completedLabel)
        
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
        
        print("Yeni oyun başlatılıyor...")
        
        // Create and shuffle a deck based on difficulty
        createDeck()
        
        print("Deste oluşturuldu, \(deck.count) kart var")
        
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
        
        print("Kartlar dağıtılıyor...")
        
        for stackIndex in 0..<GameConfig.numberOfStacks {
            let cardsInStack = (stackIndex < 4) ? 6 : 5
            
            print("Yığın #\(stackIndex): \(cardsInStack) kart dağıtılıyor")
            
            for cardIndex in 0..<cardsInStack {
                if let card = deck.popLast() {
                    // Only the top card should be face up
                    card.isRevealed = (cardIndex == cardsInStack - 1)
                    
                    // Add to appropriate stack
                    card.frame = CGRect(x: 0, y: 0, width: GameConfig.cardWidth, height: GameConfig.cardHeight)
                    stacks[stackIndex].addCard(card)
                    print("Kart dağıtıldı: \(card.value) \(card.suit), isRevealed: \(card.isRevealed)")
                } else {
                    print("HATA: Dağıtılacak kart kalmadı!")
                }
            }
        }
        
        // Remaining cards go to stock
        stockCards = deck
        deck = []
        print("Stok kartları: \(stockCards.count) kart")
        updateStockPileUI()
        
        // Kartların düzgün yerleştirildiğinden emin olalım
        for (index, stack) in stacks.enumerated() {
            print("Yığın #\(index): \(stack.cards.count) kart var")
            stack.repositionCards()
        }
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
                card.isRevealed = true // Cards from stock pile should be face up
                stacks[stackIndex].addCard(card, animated: true)
            }
        }
        
        // Update stock pile UI
        updateStockPileUI()
        
        // Provide haptic feedback
        if GameConfig.hapticFeedbackEnabled {
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
        }
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
        // Check each stack for completed sets
        for stack in stacks {
            if stack.checkForCompletedSequences() {
                // Found and processed a completed set
                completedSetCount += 1
                score += GameConfig.completeSequencePoints
                
                // Check if game is won (8 completed sets)
                if completedSetCount == 8 {
                    gameWon()
                }
                
                // Update UI
                updateLabels()
                
                // Check again since stack contents have changed
                checkForCompletedSets()
                return
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
    
    @objc private func dealCards() {
        stockPileTapped()
    }
    
    @objc private func undoMove() {
        guard !moveHistory.isEmpty else { return }
        
        let lastMove = moveHistory.removeLast()
        
        // Remove cards from destination stack
        let destinationStack = stacks[lastMove.destinationStack]
        let cardsToMove = lastMove.cards
        
        // Add cards back to source stack
        let sourceStack = stacks[lastMove.sourceStack]
        
        // Remove cards from destination
        for card in cardsToMove {
            destinationStack.removeCard(card)
        }
        
        // Add cards back to source
        sourceStack.addCards(cardsToMove)
        
        // If we revealed a card during this move, hide it again
        if lastMove.didRevealCard, let lastCard = sourceStack.cards.last {
            lastCard.flip()
        }
        
        // Update score and moves
        moves -= 1
        score -= GameConfig.moveCardPoints
        updateStatusLabels()
        
        // Provide haptic feedback
        if GameConfig.hapticFeedbackEnabled {
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred()
        }
    }
    
    private func updateStatusLabels() {
        updateLabels()
    }
    
    private func updateStockPileDisplay() {
        updateStockPileUI()
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
    
    // Gets a random suit based on difficulty level
    private func getRandomSuit() -> String {
        let availableSuits: [String]
        
        switch GameConfig.difficultyLevel {
        case .easy:
            availableSuits = ["♠"]
        case .medium:
            availableSuits = ["♠", "♥"]
        case .hard:
            availableSuits = ["♠", "♥", "♦", "♣"]
        }
        
        return availableSuits.randomElement() ?? "♠"
    }
    
    @objc private func showHint() {
        // Find a valid move
        var hintFound = false
        
        // Check each stack for movable cards
        for sourceStackIndex in 0..<stacks.count {
            let sourceStack = stacks[sourceStackIndex]
            let movableSequences = sourceStack.getMovableSequences()
            
            for sequence in movableSequences {
                // Try to find a valid destination for each sequence
                for destStackIndex in 0..<stacks.count where destStackIndex != sourceStackIndex {
                    let destStack = stacks[destStackIndex]
                    
                    if destStack.canAcceptCards(sequence) {
                        // We found a valid move, highlight it
                        sequence.first?.highlightAsHint()
                        
                        if let destCard = destStack.cards.last {
                            destCard.highlightAsMovable()
                        }
                        
                        hintFound = true
                        break
                    }
                }
                
                if hintFound {
                    break
                }
            }
            
            if hintFound {
                break
            }
        }
        
        // If no hint found, check if dealing is possible
        if !hintFound && !stockCards.isEmpty {
            // Highlight the stock pile
            UIView.animate(withDuration: 0.3, animations: {
                self.stockPile.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.stockPile.layer.borderColor = UIColor.systemYellow.cgColor
                self.stockPile.layer.borderWidth = 3.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.stockPile.transform = .identity
                    self.stockPile.layer.borderWidth = 1.0
                    self.stockPile.layer.borderColor = UIColor.white.cgColor
                }
            })
        }
    }
    
    private func checkForSavedGame() {
        // Only check if we haven't initialized a game yet
        if stacks.isEmpty || stacks[0].cards.isEmpty {
            if GameManager.shared.hasSavedGame() {
                showContinueGamePrompt()
            }
        }
    }
    
    private func showContinueGamePrompt() {
        let continueView = UIView(frame: bounds)
        continueView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let container = UIView(frame: CGRect(x: 50, y: bounds.height/2 - 100, width: bounds.width - 100, height: 200))
        container.backgroundColor = UIColor.systemBackground
        container.layer.cornerRadius = 16
        continueView.addSubview(container)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: container.bounds.width - 40, height: 30))
        titleLabel.text = "Devam Etmek İster Misiniz?"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 60, width: container.bounds.width - 40, height: 60))
        messageLabel.text = "Kaydedilmiş bir oyun bulundu. Kaldığınız yerden devam etmek ister misiniz?"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        container.addSubview(messageLabel)
        
        // Buttons
        let buttonWidth = (container.bounds.width - 60) / 2
        
        let newGameButton = UIButton(type: .system)
        newGameButton.frame = CGRect(x: 20, y: container.bounds.height - 60, width: buttonWidth, height: 40)
        newGameButton.setTitle("Yeni Oyun", for: .normal)
        newGameButton.backgroundColor = UIColor.systemRed
        newGameButton.setTitleColor(.white, for: .normal)
        newGameButton.layer.cornerRadius = 8
        newGameButton.tag = 0 // For identification
        newGameButton.addTarget(self, action: #selector(continueGameChoice(_:)), for: .touchUpInside)
        container.addSubview(newGameButton)
        
        let continueButton = UIButton(type: .system)
        continueButton.frame = CGRect(x: container.bounds.width - buttonWidth - 20, y: container.bounds.height - 60, width: buttonWidth, height: 40)
        continueButton.setTitle("Devam Et", for: .normal)
        continueButton.backgroundColor = UIColor.systemBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.tag = 1 // For identification
        continueButton.addTarget(self, action: #selector(continueGameChoice(_:)), for: .touchUpInside)
        container.addSubview(continueButton)
        
        addSubview(continueView)
        
        // Animate in
        container.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3) {
            container.transform = .identity
        }
    }
    
    @objc private func continueGameChoice(_ sender: UIButton) {
        if let promptView = sender.superview?.superview {
            UIView.animate(withDuration: 0.3, animations: {
                promptView.alpha = 0
            }, completion: { _ in
                promptView.removeFromSuperview()
                
                if sender.tag == 1 {
                    // Continue saved game
                    self.loadSavedGame()
                } else {
                    // Start new game
                    GameManager.shared.clearSavedGame()
                    self.startNewGame()
                }
            })
        }
    }
    
    private func loadSavedGame() {
        guard let savedGame = GameManager.shared.loadSavedGame() else {
            startNewGame()
            return
        }
        
        // Reset game state
        resetGame()
        
        // Restore game state
        score = savedGame.score
        moves = savedGame.moves
        elapsedTime = savedGame.elapsedTime
        completedSetCount = savedGame.completedSetCount
        GameConfig.difficultyLevel = savedGame.difficultyLevel
        seed = savedGame.seed
        isChallenge = savedGame.isChallenge
        
        // Create stock pile cards
        stockCards = []
        for _ in 0..<savedGame.stockPileCount {
            // Create face-down cards for stock
            let suit = getRandomSuit()
            let value = GameConfig.cardValues.randomElement() ?? "A"
            let card = Card(value: value, suit: suit, faceUp: false)
            stockCards.append(card)
        }
        
        // Restore card stacks
        for stackIndex in 0..<savedGame.cards.count {
            let stackState = savedGame.cards[stackIndex]
            
            for cardState in stackState {
                let card = Card(value: cardState.value, suit: cardState.suit, faceUp: cardState.isRevealed)
                card.isRevealed = cardState.isRevealed
                stacks[stackIndex].addCard(card)
            }
        }
        
        // Update UI
        updateStockPileDisplay()
        updateStatusLabels()
        
        // Start timer
        startTimer()
    }
    
    private func saveCurrentGame() {
        GameManager.shared.saveGame(
            score: score,
            moves: moves,
            elapsedTime: elapsedTime,
            difficultyLevel: GameConfig.difficultyLevel,
            completedSetCount: completedSetCount,
            stacks: stacks,
            stockPileCount: stockCards.count,
            seed: seed,
            isChallenge: isChallenge
        )
    }
    
    func startDailyChallenge(challenge: DailyChallenge) {
        // Set up a challenge game
        isChallenge = true
        currentChallenge = challenge
        GameConfig.difficultyLevel = challenge.difficulty
        seed = challenge.seed
        
        // Start a new game with the challenge seed
        startNewGame()
    }
    
    private func showGameCompleteModal() {
        // Save statistics
        let (gamesPlayed, gamesWon, bestScore, fastestTime) = GameManager.shared.loadStatistics()
        GameManager.shared.saveStatistics(
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon + 1,
            bestScore: max(bestScore, score),
            fastestTime: elapsedTime > 0 ? (fastestTime > 0 ? min(fastestTime, elapsedTime) : elapsedTime) : fastestTime
        )
        
        // If this was a challenge, mark it as completed
        if isChallenge, let challenge = currentChallenge {
            challenge.saveCompletion(score: score, time: elapsedTime)
        }
        
        // Clear saved game
        GameManager.shared.clearSavedGame()
        
        let winView = UIView(frame: bounds)
        winView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let container = UIView(frame: CGRect(x: 50, y: bounds.height/2 - 150, width: bounds.width - 100, height: 300))
        container.backgroundColor = UIColor.systemBackground
        container.layer.cornerRadius = 16
        winView.addSubview(container)
        
        // Confetti effect
        addConfettiEffect(to: winView)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 20, width: container.bounds.width - 40, height: 40))
        titleLabel.text = "Tebrikler!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        container.addSubview(titleLabel)
        
        // Format time
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 70, width: container.bounds.width - 40, height: 150))
        messageLabel.text = """
            Oyunu başarıyla tamamladınız!
            
            Puan: \(score)
            Hamle: \(moves)
            Süre: \(timeString)
            Zorluk: \(GameConfig.difficultyLevel.description)
            
            \(isChallenge ? "Günlük Meydan Okumayı Tamamladınız!" : "")
        """
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        container.addSubview(messageLabel)
        
        let newGameButton = UIButton(type: .system)
        newGameButton.frame = CGRect(x: container.bounds.width/2 - 60, y: container.bounds.height - 60, width: 120, height: 40)
        newGameButton.setTitle("Yeni Oyun", for: .normal)
        newGameButton.backgroundColor = UIColor.systemBlue
        newGameButton.setTitleColor(.white, for: .normal)
        newGameButton.layer.cornerRadius = 8
        newGameButton.addTarget(self, action: #selector(newGameAfterWin), for: .touchUpInside)
        container.addSubview(newGameButton)
        
        addSubview(winView)
        
        // Animate in
        container.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            container.transform = .identity
        }, completion: nil)
        
        // Play win sound
        if GameConfig.soundEnabled {
            // Sound would be played here
        }
        
        // Provide success haptic feedback
        if GameConfig.hapticFeedbackEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
        }
    }
    
    @objc private func newGameAfterWin(_ sender: UIButton) {
        if let winView = sender.superview?.superview {
            UIView.animate(withDuration: 0.3, animations: {
                winView.alpha = 0
            }, completion: { _ in
                winView.removeFromSuperview()
                self.startNewGame()
            })
        }
    }
    
    private func addConfettiEffect(to view: UIView) {
        let confettiColors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPurple, .systemOrange]
        let confettiShapes = ["■", "●", "▲", "★", "♦️", "♣️", "♥️", "♠️"]
        
        for _ in 0..<100 {
            let confetti = UILabel()
            confetti.text = confettiShapes.randomElement()
            confetti.textColor = confettiColors.randomElement()
            confetti.font = UIFont.systemFont(ofSize: CGFloat.random(in: 10...20))
            
            let startX = CGFloat.random(in: 0...bounds.width)
            let startY = -20
            
            confetti.frame = CGRect(x: startX, y: CGFloat(startY), width: 20, height: 20)
            view.addSubview(confetti)
            
            let duration = TimeInterval.random(in: 2...4)
            let delay = TimeInterval.random(in: 0...1)
            
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseOut], animations: {
                confetti.frame.origin.y = self.bounds.height + 20
                confetti.frame.origin.x += CGFloat.random(in: -50...50)
                confetti.transform = CGAffineTransform(rotationAngle: .pi * 2 * CGFloat.random(in: 1...3))
                confetti.alpha = 0
            }, completion: { _ in
                confetti.removeFromSuperview()
            })
        }
    }
    
    func updateSettings() {
        // Update visibility of UI elements based on settings
        timerLabel?.isHidden = !GameConfig.showTimer
        scoreLabel?.isHidden = !GameConfig.showScore
        
        // Refresh toolbar
        setupToolbar()
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
                // Make sure card is face up
                if !card.isRevealed {
                    return
                }
                
                // Check if the card is part of a valid sequence
                if let cardsToMove = stack.cardsFromCard(card) {
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
                    if let cardIndex = stack.indexOf(card: card) {
                        _ = stack.removeCards(from: cardIndex)
                    }
                    
                    // Apply haptic feedback when starting to drag
                    if GameConfig.hapticFeedbackEnabled {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
                    
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
        
        // Get current position of first card
        if let firstCard = cards.first, let originStack = dragOriginStack {
            let firstCardFrame = originStack.convert(firstCard.frame, to: self)
            cardSnapshot?.frame.origin = firstCardFrame.origin
        }
        
        // Add each card to the snapshot
        for (index, card) in cards.enumerated() {
            let cardCopy = Card(value: card.value, suit: card.suit, faceUp: true)
            cardCopy.isRevealed = true
            cardCopy.frame.origin.y = CGFloat(index) * GameConfig.cardOverlap
            cardSnapshot?.addSubview(cardCopy)
            
            // Add subtle shadow effect to make dragged cards stand out
            cardCopy.layer.shadowColor = UIColor.black.cgColor
            cardCopy.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardCopy.layer.shadowRadius = 3
            cardCopy.layer.shadowOpacity = 0.3
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
        var targetFound = false
        
        for stack in stacks {
            // Use converted frame for proper hit testing
            let stackFrame = stack.convert(stack.bounds, to: self)
            
            // Expand the hit testing area slightly to make it easier to drop cards
            let expandedFrame = stackFrame.insetBy(dx: -20, dy: -20)
            
            if expandedFrame.contains(location) {
                targetStack = stack
                targetFound = true
                break
            }
        }
        
        // Either place cards in target stack if valid move, or return to origin stack
        if targetFound, let targetStack = targetStack {
            if targetStack.canAcceptCards(cards) {
                // Success haptic feedback
                if GameConfig.hapticFeedbackEnabled {
                    let feedback = UIImpactFeedbackGenerator(style: .medium)
                    feedback.impactOccurred()
                }
                
                // Add the cards to the target stack
                targetStack.addCards(cards, animated: true)
                
                // Increment move count
                moves += 1
                
                // Check for completed sets
                checkForCompletedSets()
                
                // Update UI
                updateLabels()
                
                // Save game state after each move
                saveCurrentGame()
            } else {
                // Not a valid move - error haptic feedback  
                if GameConfig.hapticFeedbackEnabled {
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.error)
                }
                
                // Return cards to original stack
                originStack.addCards(cards, animated: true)
            }
        } else {
            // No target stack found, return cards to original stack
            originStack.addCards(cards, animated: true)
        }
        
        // Clean up
        snapshot.removeFromSuperview()
        cardSnapshot = nil
        draggingCards = nil
        draggingCard = nil
        dragOriginStack = nil
    }
    
    func updateTheme() {
        // Update background
        backgroundColor = getThemeBackgroundColor()
        
        // Update card backs
        for stack in stacks {
            for card in stack.cards {
                card.updateTheme()
            }
        }
        
        // Update stock pile cards
        for subview in stockPile.subviews where subview is Card {
            if let card = subview as? Card {
                card.updateTheme()
            }
        }
    }
} 