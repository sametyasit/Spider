//
//  ViewController.swift
//  Spider
//
//  Created by Samet on 29/04/2025.
//

import UIKit

class ViewController: UIViewController {
    
    private var gameView: SpiderSolitaireView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the game view
        gameView = SpiderSolitaireView(frame: view.bounds)
        view.addSubview(gameView)
        
        // Setup game
        setupNewGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gameView frame when view layout changes
        gameView.frame = view.bounds
        gameView.layoutIfNeeded()
    }
    
    private func setupNewGame() {
        gameView.startNewGame()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

