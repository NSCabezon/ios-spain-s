//
//  NumberPadButton.swift
//  UI
//
//  Created by Juan Carlos López Robles on 12/14/20.
//

import Foundation
import UIKit

class NumberPadButton: UIButton {

    @IBInspectable var pressedColor: UIColor?
    @IBInspectable var normalColor: UIColor? {
        willSet { self.backgroundColor = newValue }
    }
    
    @IBInspectable var radius: CGFloat = 0.0 {
        willSet { self.layer.cornerRadius = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        NotificationCenter.default.addObserver(self, selector: #selector(resetColor), name: UIApplication.didBecomeActiveNotification, object: nil)
        addLongPressGesture()
    }
    
    func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPresseButton))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.allowableMovement = 0.0
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    func didPresseButton(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.backgroundColor = pressedColor
        } else if gestureRecognizer.state == .ended {
            self.backgroundColor = normalColor
        }
    }

    @objc private func resetColor() {
        self.backgroundColor = normalColor
    }
}

extension NumberPadButton: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            return true
    }
}
