//
//  PresedButton.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/27/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

//Remove when login storyboard does't exists
import UIKit

class PresedButton: UIButton {

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
}

extension PresedButton: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            return true
    }
}
