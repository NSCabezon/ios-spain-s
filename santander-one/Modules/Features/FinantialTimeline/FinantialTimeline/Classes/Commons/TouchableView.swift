//
//  TouchableView.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 23/07/2019.
//

import Foundation

class TouchableView: UIView {
    
    // MARK: - Private attributes
    
    private var completion: (() -> Void)?
    
    // MARK: - Public methods
    
    func addAction(completion: @escaping (() -> Void)) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(performAction))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.completion = completion
    }
    
    // MARK: - Actions
    
    @objc private func performAction() {
        self.completion?()
    }
}
