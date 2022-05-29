//
//  SwipeableView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/15/20.
//

import Foundation

protocol SwipeableViewDelegate: AnyObject {
    func didSwipeBegin()
}

final class SwipeableView: UIView {
    private var swipeView: UIView?
    private let swipe = Swipe()
    private weak var delegate: SwipeableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func allowSwipe() {
        self.swipeView = self.subviews.last
        self.addSwipeGesture()
    }
    
    func setDelegate(_ delegate: SwipeableViewDelegate) {
        self.delegate = delegate
    }
    
    func setDefaultPosition() {
        guard let swipeView = self.swipeView else { return }
        let point = CGPoint(x: 0, y: swipeView.frame.origin.y)
        let originalFrame = CGRect(origin: point, size: swipeView.bounds.size)
        swipeView.frame = originalFrame
        self.hideShadow()
    }
    
    func swipeToOriginWithAnimation() {
        self.adjustSwipeViewHorizontally(to: swipe.defaultPosition)
        self.hideShadow()
    }
}

private extension SwipeableView {
    private func addSwipeGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe))
        panGesture.delegate = self
        self.swipeView?.addGestureRecognizer(panGesture)
    }
    
    @objc
    private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let swipeView = self.swipeView else { return }
        switch gesture.state {
        case .began:
            self.swipe.originalPoint = swipeView.center
        case.changed:
            let xPosition = gesture.translation(in: swipeView).x
            guard gesture.direction() != .none else { return }
            guard swipe.range ~= xPosition else { return }
            let direction = gesture.direction()
            let point = swipe.translation(in: xPosition, ondirection: direction)
            self.moveSwipeView(to: point)
            self.showShandow()
        case .ended:
            self.adjustSwipeViewHorizontalPosition()
        default: break
        }
    }
    
    private func moveSwipeView(to point: CGPoint) {
        guard let swipeView = self.swipeView else { return }
        swipeView.center = point
        self.swipe.allow.right = swipeView.frame.origin.x < swipe.maxValue.right
        self.swipe.allow.left = swipeView.frame.origin.x > swipe.maxValue.left
        self.delegate?.didSwipeBegin()
    }
    
    private func adjustSwipeViewHorizontalPosition() {
        if self.swipe.allow.right {
            self.adjustSwipeViewHorizontally(to: swipe.maxValue.right)
        } else if self.swipe.allow.left {
            self.adjustSwipeViewHorizontally(to: swipe.maxValue.left)
        } else {
            self.swipeToOriginWithAnimation()
        }
    }
    
    private func adjustSwipeViewHorizontally(to xPosition: CGFloat) {
        guard let swipeView = self.swipeView else { return }
        let point = CGPoint(x: xPosition, y: swipeView.frame.origin.y)
        let originalFrame = CGRect(origin: point, size: swipeView.bounds.size)
        UIView.animate(withDuration: 0.2, animations: {
            swipeView.frame = originalFrame
        })
    }
    
    private func showShandow() {
        self.swipeView?.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.swipeView?.layer.shadowOpacity = 1
        self.swipeView?.layer.shadowOffset = CGSize(width: 0, height: -2)
    }
    
    private func hideShadow() {
        self.swipeView?.layer.shadowColor = UIColor.clear.cgColor
    }
}

extension SwipeableView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesturen = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        guard let swipeView = panGesturen.view else { return false }
        let translation = panGesturen.translation(in: swipeView)
        guard abs(translation.x) > abs(translation.y) else { return false }
        return true
    }
}
