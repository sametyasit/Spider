//
//  DailyChallengeViewController.swift
//  Spider
//
//  Created by Samet on 01/05/2025.
//

import UIKit

class DailyChallengeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var calendarView: UICollectionView!
    private var challenges: [GameConfig.DailyChallenge] = []
    private var monthLabel: UILabel!
    private var closeButton: UIButton!
    
    // Layout constants
    private let cellSize: CGFloat = 50
    private let cellSpacing: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadChallenges()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Set up header and month display
        setupHeader()
        
        // Set up calendar collection view
        setupCalendarView()
        
        // Add footer buttons
        setupFooter()
    }
    
    private func setupHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80))
        
        // Month label
        monthLabel = UILabel(frame: CGRect(x: 50, y: 20, width: view.bounds.width - 100, height: 40))
        monthLabel.text = getCurrentMonthName()
        monthLabel.font = UIFont.boldSystemFont(ofSize: 22)
        monthLabel.textAlignment = .center
        headerView.addSubview(monthLabel)
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray
        closeButton.frame = CGRect(x: view.bounds.width - 60, y: 20, width: 40, height: 40)
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        headerView.addSubview(closeButton)
        
        view.addSubview(headerView)
    }
    
    private func setupCalendarView() {
        // Weekday headers
        let weekdayHeight: CGFloat = 30
        let weekdayView = UIView(frame: CGRect(x: 0, y: 80, width: view.bounds.width, height: weekdayHeight))
        
        let weekdays = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]
        let weekdayWidth = view.bounds.width / CGFloat(weekdays.count)
        
        for (index, day) in weekdays.enumerated() {
            let label = UILabel(frame: CGRect(x: CGFloat(index) * weekdayWidth, y: 0, width: weekdayWidth, height: weekdayHeight))
            label.text = day
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .systemGray
            weekdayView.addSubview(label)
        }
        
        view.addSubview(weekdayView)
        
        // Calendar collection layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = cellSpacing
        layout.minimumInteritemSpacing = cellSpacing
        
        // Calculate cell width to fit 7 cells across
        let totalCellsAcross: CGFloat = 7
        let totalSpacingAcross: CGFloat = cellSpacing * (totalCellsAcross - 1)
        let availableWidth = view.bounds.width - 40 // 20pt padding on each side
        let cellWidth = (availableWidth - totalSpacingAcross) / totalCellsAcross
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        // Calendar collection view
        let collectionTop = 80 + weekdayHeight + 10
        let collectionFrame = CGRect(x: 20, y: collectionTop, width: view.bounds.width - 40, height: view.bounds.height - collectionTop - 100)
        
        calendarView = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        calendarView.backgroundColor = .clear
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.register(ChallengeCell.self, forCellWithReuseIdentifier: "ChallengeCell")
        calendarView.showsVerticalScrollIndicator = false
        
        view.addSubview(calendarView)
    }
    
    private func setupFooter() {
        let footerHeight: CGFloat = 80
        let footerY = view.bounds.height - footerHeight
        let footerView = UIView(frame: CGRect(x: 0, y: footerY, width: view.bounds.width, height: footerHeight))
        footerView.backgroundColor = UIColor.systemGray6
        
        // Today's challenge button
        let todayButton = UIButton(type: .system)
        todayButton.frame = CGRect(x: (view.bounds.width - 200) / 2, y: 20, width: 200, height: 40)
        todayButton.setTitle("Bugünün Meydan Okuması", for: .normal)
        todayButton.backgroundColor = UIColor.systemBlue
        todayButton.setTitleColor(.white, for: .normal)
        todayButton.layer.cornerRadius = 10
        todayButton.addTarget(self, action: #selector(startTodaysChallenge), for: .touchUpInside)
        footerView.addSubview(todayButton)
        
        view.addSubview(footerView)
    }
    
    private func getCurrentMonthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "tr_TR")
        return dateFormatter.string(from: Date())
    }
    
    private func loadChallenges() {
        challenges = GameConfig.DailyChallenge.forCurrentMonth()
        
        // Calculate first weekday offset
        addEmptyCellsForMonthStart()
        
        calendarView.reloadData()
    }
    
    private func addEmptyCellsForMonthStart() {
        guard let firstChallenge = challenges.first else { return }
        
        let calendar = Calendar.current
        let firstDay = calendar.component(.day, from: firstChallenge.date)
        
        if firstDay > 1 {
            // We need to add empty cells for the days before the first day of the month
            let components = calendar.dateComponents([.year, .month], from: firstChallenge.date)
            guard let firstOfMonth = calendar.date(from: components) else { return }
            
            let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
            // Adjust for Monday being first day of week (1 in Turkish calendar)
            let adjustedWeekday = (firstWeekday + 5) % 7 + 1
            
            // Add empty challenges for the weekdays before the first of the month
            for _ in 0..<(adjustedWeekday - 1) {
                let emptyChallenge = GameConfig.DailyChallenge(
                    id: 0,
                    name: "Empty",
                    difficulty: .easy,
                    seed: 0,
                    date: Date.distantPast
                )
                challenges.insert(emptyChallenge, at: 0)
            }
        }
    }
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
    
    @objc private func startTodaysChallenge() {
        let todayChallenge = GameConfig.DailyChallenge.forToday()
        dismiss(animated: true) {
            // Notify the game view to start today's challenge
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let rootViewController = sceneDelegate.window?.rootViewController as? ViewController {
                rootViewController.spiderView.startDailyChallenge(challenge: todayChallenge)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return challenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChallengeCell", for: indexPath) as! ChallengeCell
        
        let challenge = challenges[indexPath.item]
        
        // Check if this is an empty cell (padding at start of month)
        if challenge.id == 0 && challenge.name == "Empty" {
            cell.configure(day: "", difficulty: nil, isCompleted: false, isToday: false, isEmpty: true)
            return cell
        }
        
        // Get the day number
        let calendar = Calendar.current
        let day = calendar.component(.day, from: challenge.date)
        
        // Check if this is today
        let isToday = calendar.isDateInToday(challenge.date)
        
        // Check if the challenge date is in the future
        let isFuture = challenge.date > Date()
        
        // Configure the cell
        cell.configure(
            day: "\(day)",
            difficulty: challenge.difficulty,
            isCompleted: challenge.isCompleted,
            isToday: isToday,
            isEmpty: false,
            isFuture: isFuture
        )
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let challenge = challenges[indexPath.item]
        
        // Don't allow selection of empty cells or future dates
        if challenge.id == 0 && challenge.name == "Empty" {
            return
        }
        
        if challenge.date > Date() {
            return
        }
        
        // Close modal and start selected challenge
        dismiss(animated: true) {
            // Notify the game view to start the selected challenge
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let rootViewController = sceneDelegate.window?.rootViewController as? ViewController {
                rootViewController.spiderView.startDailyChallenge(challenge: challenge)
            }
        }
    }
}

// MARK: - Challenge Cell

class ChallengeCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let completionIndicator = UIImageView()
    private let difficultyIndicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.backgroundColor = UIColor.systemGray6
        
        // Day label
        dayLabel.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
        dayLabel.textAlignment = .center
        dayLabel.font = UIFont.boldSystemFont(ofSize: 16)
        contentView.addSubview(dayLabel)
        
        // Completion indicator
        completionIndicator.frame = CGRect(x: contentView.bounds.width - 18, y: 2, width: 16, height: 16)
        completionIndicator.image = UIImage(systemName: "checkmark.circle.fill")
        completionIndicator.tintColor = UIColor.systemGreen
        completionIndicator.isHidden = true
        contentView.addSubview(completionIndicator)
        
        // Difficulty indicator
        let indicatorSize: CGFloat = 8
        difficultyIndicator.frame = CGRect(
            x: (contentView.bounds.width - indicatorSize) / 2,
            y: contentView.bounds.height - indicatorSize - 2,
            width: indicatorSize,
            height: indicatorSize
        )
        difficultyIndicator.layer.cornerRadius = indicatorSize / 2
        contentView.addSubview(difficultyIndicator)
    }
    
    func configure(day: String, difficulty: GameConfig.DifficultyLevel?, isCompleted: Bool, isToday: Bool, isEmpty: Bool, isFuture: Bool = false) {
        dayLabel.text = day
        
        // Empty cell styling
        if isEmpty {
            contentView.backgroundColor = .clear
            contentView.layer.borderColor = UIColor.clear.cgColor
            dayLabel.text = ""
            completionIndicator.isHidden = true
            difficultyIndicator.isHidden = true
            return
        }
        
        // Future date styling
        if isFuture {
            contentView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
            contentView.layer.borderColor = UIColor.systemGray5.cgColor
            dayLabel.textColor = UIColor.systemGray3
            completionIndicator.isHidden = true
            difficultyIndicator.isHidden = true
            return
        }
        
        // Today styling
        if isToday {
            contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
            dayLabel.textColor = UIColor.systemBlue
        } else {
            contentView.backgroundColor = isCompleted ? UIColor.systemGreen.withAlphaComponent(0.1) : UIColor.systemGray6
            contentView.layer.borderColor = isCompleted ? UIColor.systemGreen.cgColor : UIColor.systemGray5.cgColor
            dayLabel.textColor = .label
        }
        
        // Show completion indicator if challenge is completed
        completionIndicator.isHidden = !isCompleted
        
        // Set difficulty indicator color
        if let difficulty = difficulty {
            switch difficulty {
            case .easy:
                difficultyIndicator.backgroundColor = .systemGreen
            case .medium:
                difficultyIndicator.backgroundColor = .systemOrange
            case .hard:
                difficultyIndicator.backgroundColor = .systemRed
            }
            difficultyIndicator.isHidden = false
        } else {
            difficultyIndicator.isHidden = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = ""
        completionIndicator.isHidden = true
        difficultyIndicator.isHidden = true
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
    }
} 