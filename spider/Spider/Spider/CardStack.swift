//
//  CardStack.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

class CardStack: UIView {
    
    // MARK: - Properties
    
    internal var cards: [Card] = []
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
        emptyIndicator = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: GameConfig.cardHeight))
        emptyIndicator.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        emptyIndicator.layer.cornerRadius = 8
        emptyIndicator.layer.borderWidth = 1
        emptyIndicator.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Plus icon and text
        let plusLabel = UILabel(frame: emptyIndicator.bounds)
        plusLabel.text = "+"
        plusLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        plusLabel.font = UIFont.systemFont(ofSize: 24, weight: .light)
        plusLabel.textAlignment = .center
        emptyIndicator.addSubview(plusLabel)
        
        // Hide initially if we have cards
        emptyIndicator.isHidden = !cards.isEmpty
        
        addSubview(emptyIndicator)
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
    
    func addCards(_ newCards: [Card], animated: Bool = false) {
        // Kartları yığına ekle
        for newCard in newCards {
            addCard(newCard)
        }
        
        // Animasyonlu ekleme istenirse
        if animated {
            // İlk kart için pozisyon belirle
            let startY = cards.count > newCards.count ? 
                CGFloat(cards.count - newCards.count) * GameConfig.cardOverlap : 0
            
            for (index, card) in newCards.enumerated() {
                let finalY = startY + CGFloat(index) * GameConfig.cardOverlap
                
                // Başlangıçta kartın eklenmesi ve efektle animasyon
                card.alpha = 0.7
                card.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                
                UIView.animate(withDuration: 0.2, delay: 0.03 * Double(index), options: .curveEaseOut, animations: {
                    card.alpha = 1.0
                    card.transform = .identity
                    card.frame.origin.y = finalY
                }, completion: nil)
                
                // Kartı öne getir
                bringSubviewToFront(card)
            }
        } else {
            // Animasyonsuz düzenleme
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
        
        // Tüm kartları kaldıralım ve sonra yeniden ekleyelim
        for card in cards {
            card.removeFromSuperview()
        }
        
        for (index, card) in cards.enumerated() {
            // Calculate position
            let yOffset = index > 0 ? CGFloat(index) * GameConfig.cardOverlap : 0
            let targetFrame = CGRect(
                x: 0,
                y: yOffset,
                width: min(frame.width, GameConfig.cardWidth),
                height: GameConfig.cardHeight
            )
            
            // Kartı direkt olarak doğru pozisyonda ekleyelim
            card.frame = targetFrame
            addSubview(card)
            
            // Son kart görünür, sürüklemede önemli
            if index == cards.count - 1 {
                bringSubviewToFront(card)
            }
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
    func canAcceptCards(_ draggedCards: [Card]) -> Bool {
        // Boş ise herhangi bir kartı (başlangıç olarak K veya herhangi bir kart) kabul et
        if cards.isEmpty {
            // Boş bir yığın istediğimiz herhangi bir değeri kabul edebilir
            return true
        }
        
        // Sadece sürüklenebilir kartları kabul et
        guard let draggedTopCard = draggedCards.first, draggedTopCard.isDraggable else {
            return false
        }
        
        // Üstteki kartı al
        guard let topCard = cards.last else {
            return true
        }
        
        // Üstteki kart açık değilse sürükleme yapılamaz
        guard topCard.isRevealed else {
            return false
        }
        
        // Kart değerleri ve takımlar kontrol edilir
        // Spider Solitaire kuralı: Daha büyük değer üzerine sadece bir küçük değer gelebilir
        let topCardIndex = GameConfig.cardValues.firstIndex(of: topCard.value) ?? 0
        let draggedCardIndex = GameConfig.cardValues.firstIndex(of: draggedTopCard.value) ?? 0
        
        // Sürüklenen kart, hedef karttan bir değer küçük olmalıdır
        // Ör: Hedef kart J ise, sürüklenen kart 10 olmalıdır
        let correctValue = (topCardIndex == draggedCardIndex + 1)
        
        // Zorluk seviyesine göre eşleşme kontrolü
        switch GameConfig.difficultyLevel {
        case .easy:
            // Kolay seviyede sadece değer sırası önemli, takım önemli değil
            return correctValue
            
        case .medium:
            // Orta seviyede eğer takımlar aynıysa sıra kontrolü yaparız
            // Farklı takımlarsa, yine değer kontrolü yeterli
            let sameSuit = topCard.suit == draggedTopCard.suit
            return correctValue && (sameSuit || !GameConfig.requireSameSuitForMedium)
            
        case .hard:
            // Zor seviyede sadece aynı takımdan kartlar kabul edilir
            let sameSuit = topCard.suit == draggedTopCard.suit
            return correctValue && sameSuit
        }
    }
    
    // Get all sequences of cards that can be moved
    func getMovableSequences() -> [[Card]] {
        var movableSequences: [[Card]] = []
        
        // Her karttan başlayarak olası tüm sıraları bul
        for i in 0..<cards.count {
            let startCard = cards[i]
            
            // Kart açık değilse, atla
            if !startCard.isRevealed {
                continue
            }
            
            // Bu karttan başlayan bir sıra olabilir
            let cardSubset = Array(cards[i...])
            
            // Tüm olası sıraları kontrol et
            for length in 1...cardSubset.count {
                let possibleSequence = Array(cardSubset.prefix(length))
                
                // Bu geçerli bir sıra mı?
                if isValidSequence(possibleSequence) {
                    movableSequences.append(possibleSequence)
                }
            }
        }
        
        return movableSequences
    }
    
    // Check for and handle completed sequences (K to A of same suit)
    func checkForCompletedSequences() -> Bool {
        // Yığında en az 13 kart olmalı (Tam bir deste oluşturmak için)
        guard cards.count >= 13 else {
            return false
        }
        
        // Son 13 kartı kontrol et
        let startIndex = cards.count - 13
        let potentialSequence = Array(cards[startIndex...])
        
        // Kartlar K'dan A'ya sıralı olmalı
        let values = Array(GameConfig.cardValues.reversed()) // K, Q, J, ..., A
        
        // Sıralamanın doğru olup olmadığını kontrol et
        for i in 0..<potentialSequence.count {
            let card = potentialSequence[i]
            
            // Kart açık değilse, geçersiz
            if !card.isRevealed {
                return false
            }
            
            // Değer doğru mu?
            if card.value != values[i] {
                return false
            }
            
            // Tüm kartlar aynı takımdan olmalı
            if i > 0 && card.suit != potentialSequence[0].suit {
                return false
            }
        }
        
        // Sequence tamamlandı, animasyon göster ve kartları kaldır
        animateCompletedSequence(potentialSequence)
        return true
    }
    
    // MARK: - Animations
    
    // Animate a completed sequence and remove it
    private func animateCompletedSequence(_ completedCards: [Card]) {
        // Başarı sesi çal
        if GameConfig.soundEnabled {
            // Ses burada çalınacak
        }
        
        // Başarı haptic feedback
        if GameConfig.hapticFeedbackEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        
        // Animation delay
        var delay: TimeInterval = 0
        
        // Önce kartları kopyala (referans için)
        let originalCards = completedCards
        
        // Her kartı animasyonla kaldır
        for card in originalCards.reversed() {
            // Kartın pozisyonunu ekran koordinatlarına çevir
            let cardFrameInSuperview = convert(card.frame, to: superview?.superview)
            
            // Orijinal kopyası oluştur
            let cardCopy = Card(value: card.value, suit: card.suit, faceUp: true)
            cardCopy.frame = cardFrameInSuperview
            cardCopy.isRevealed = true
            superview?.superview?.addSubview(cardCopy)
            
            // Orijinal kartı gizle ve kaldır
            card.isHidden = true
            
            // Kartın yeni pozisyonu (ekranın alt tarafına)
            let endY = (superview?.superview?.bounds.height ?? 500) - 100
            
            // Animasyonla kart tamamlanan kısma hareket eder
            UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseInOut, animations: {
                cardCopy.center.y = endY
                cardCopy.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: { _ in
                // Animasyon bitince kartı kaldır
                cardCopy.removeFromSuperview()
                
                // Orijinal kartı yığından kaldır
                if let index = self.cards.firstIndex(of: card) {
                    self.cards.remove(at: index)
                    card.removeFromSuperview()
                }
                
                // Tüm kartlar kaldırıldığında en üstteki kartı aç
                if delay == 0.4 * 12 {
                    // Yeni en üstteki kartı göster
                    self.repositionCards()
                    
                    // Son kartı aç
                    if let lastCard = self.cards.last, !lastCard.isRevealed {
                        lastCard.flip()
                    }
                }
            })
            
            delay += 0.04
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
        // Pozisyonu kendi koordinat sistemimize çevirelim
        let localPoint = convert(point, from: superview)
        
        // Kartları sondan başa doğru kontrol et (üstte olan kartlar önce işlensin)
        for i in stride(from: cards.count - 1, through: 0, by: -1) {
            let card = cards[i]
            
            // Eğer pozisyon kartın sınırları içindeyse ve kart açıksa
            let cardFrame = card.frame
            
            // Dokunma alanını biraz genişlet
            let expandedFrame = CGRect(
                x: cardFrame.minX - 5,
                y: cardFrame.minY - 5,
                width: cardFrame.width + 10,
                height: cardFrame.height + 10
            )
            
            if expandedFrame.contains(localPoint) && card.isRevealed {
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
    func cardsFromCard(_ startCard: Card) -> [Card]? {
        // Başlangıç kartının indexini bul
        guard let index = indexOf(card: startCard) else {
            return nil
        }
        
        // Başlangıç kartı açık değilse, geçersiz
        guard startCard.isRevealed else {
            return nil
        }
        
        // Bu karttan sonra gelen tüm kartları al
        let startCards = Array(cards[index...])
        
        // Sıralı bir dizi mi kontrol et
        if isValidSequence(startCards) {
            // Sıralamanın doğru olduğunu belirtmek için haptic feedback
            if GameConfig.hapticFeedbackEnabled {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            return startCards
        }
        
        // Sıralanmamış kartlarda, sadece tek bir kartı taşımaya izin ver
        if index == cards.count - 1 {
            return [startCard]
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
    
    func isValidSequence(_ cardsToCheck: [Card]) -> Bool {
        // En az bir kart olmalı
        guard !cardsToCheck.isEmpty else {
            return false
        }
        
        // Tek kart her zaman geçerli bir dizi
        if cardsToCheck.count == 1 {
            return true
        }
        
        // Ardışık kartlar için kontrol
        for i in 0..<cardsToCheck.count-1 {
            let currentCard = cardsToCheck[i]
            let nextCard = cardsToCheck[i+1]
            
            // Kart değerlerinin indekslerini bul
            guard let currentIndex = GameConfig.cardValues.firstIndex(of: currentCard.value),
                  let nextIndex = GameConfig.cardValues.firstIndex(of: nextCard.value) else {
                return false
            }
            
            // Sonraki kart bir küçük değere sahip olmalı
            if nextIndex != currentIndex - 1 {
                return false
            }
            
            // Zorluğa göre takım kontrolü
            switch GameConfig.difficultyLevel {
            case .easy:
                // Kolay seviyede takım kontrolü yapma
                continue
                
            case .medium:
                // Orta seviyede, eğer sıkı kural isteniyorsa takım kontrolü yap
                if GameConfig.requireSameSuitForMedium && currentCard.suit != nextCard.suit {
                    return false
                }
                
            case .hard:
                // Zor seviyede takımlar aynı olmalı
                if currentCard.suit != nextCard.suit {
                    return false
                }
            }
        }
        
        return true
    }
    
    func highlightValidDropTarget() {
        // Kartların bırakılabileceği bir hedef olarak vurgula
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.systemGreen.cgColor
        
        // Kısa bir süre sonra vurgulamayı kaldır
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
    }
} 