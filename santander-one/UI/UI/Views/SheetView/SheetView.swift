//
//  SheetView.swift
//  SheetView
//
//  Created by Juan Carlos López Robles on 4/1/20.
//  Copyright © 2020 Juan Carlos López Robles. All rights reserved.
//

import UIKit

final class BackgroundSheetView: UIView, TopWindowViewProtocol {}

open class SheetView: UIView, TopWindowViewProtocol {
    private var backgroundView: BackgroundSheetView? = BackgroundSheetView()
    private var viewContainer: SheetViewContainer? = SheetViewContainer()
    private var defaultAlpha: CGFloat = 0.8
    private let finalBackgroundAlpha: CGFloat = 0.5
    private var animationDuration = TimeInterval(0.5)
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var initialBottomConstraintValue: CGFloat = 0.0
    private lazy var panGesture: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
        return panGesture
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setBackgroundAlpha(_ alpha: CGFloat) {
        self.defaultAlpha = alpha
    }
    
    public func setAnimationDuration(duration: CGFloat) {
        self.animationDuration = TimeInterval(duration)
    }
    
    public func addContentView(_ view: UIView) {
        self.viewContainer = self.viewContainer ?? SheetViewContainer()
        self.viewContainer?.contentView.addSubview(view)
        view.fullFit()
    }
    
    public func addScrollableContent(_ content: SheetScrollableContent) {
        self.viewContainer = self.viewContainer ?? SheetViewContainer()
        content.setup(with: getContentView())
    }
    
    public func showDragIdicator() {
        self.viewContainer?.showDragIdicator()
        self.addSwipeGesture()
    }
    
    public func getContentView() -> UIView {
        return self.viewContainer?.contentView ?? UIView()
    }
    
    public func removeContent() {
        self.viewContainer?.contentView
            .subviews.forEach { $0.removeFromSuperview() }
    }
    
    open override func addSubview(_ view: UIView) {
        super.addSubview(view)
        print("SheetView: you must be used 'addContentView' or 'addScrollableContent' to add content")
    }
    
    public func show() {
        self.setupBackgroundView()
        self.setupAppearance()
        self.addBackgroundView()
        self.addViewContainer()
        self.startAnimation()
    }
    
    public func closeWithoutAnimation() {
        guard let window = UIApplication.shared.windows.first else { return }
        let alienViews = window.subviews.suffix(from: 1)
        alienViews.forEach { (view) in
            view.removeFromSuperview()
        }
        self.viewContainer = nil
        self.backgroundView = nil
    }
    
    @objc public func closeWithAnimation() {
        self.closeWithAnimationAndCompletion()
    }
    
    public func closeWithAnimationAndCompletion(completedAnimation: (() -> Void)? = nil) {
        guard let parentView = self.viewContainer?.superview else { return }
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.backgroundView?.alpha = 0
                self?.viewContainer?.frame.origin = CGPoint(x: 0, y: parentView.frame.height)
            }, completion: { [weak self] completed in
                guard completed, let closeView = self?.viewContainer?.getCloseView() else { return }
                closeView.gestureRecognizers = nil
                self?.backgroundView?.removeFromSuperview()
                self?.viewContainer?.removeFromSuperview()
                completedAnimation?()
        })
    }
}

private extension SheetView {
    func setupAppearance() {
        self.backgroundView?.alpha = 0
        self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(defaultAlpha)
        self.viewContainer?.isOpaque = false
        self.addCloseTapGesture()
    }
    
    func setupBackgroundView() {
        guard self.backgroundView == nil else { return }
        self.backgroundView = BackgroundSheetView()
    }
    
    func addBackgroundView() {
        guard let window = UIApplication.shared.windows.first else { return }
        self.backgroundView?.frame = window.frame
        window.addSubview(self.backgroundView ?? UIView())
    }
    
    func addViewContainer() {
        guard let window = UIApplication.shared.windows.first,
              let sheetContainer = self.viewContainer else { return }
        window.addSubview(sheetContainer)
        self.addViewContainerConstraints(parentView: window)
    }
    
    func addViewContainerConstraints(parentView: UIView) {
        guard let sheetContainer = self.viewContainer else { return }
        self.viewContainer?.clipsToBounds = true
        self.viewContainer?.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraintHight = sheetContainer.bottomAnchor.constraint(greaterThanOrEqualTo: parentView.bottomAnchor)
        bottomConstraintHight.priority = .defaultHigh
        let bottomConstraintLow = sheetContainer.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        bottomConstraintLow.priority = .defaultLow
        self.bottomConstraint = bottomConstraintLow
        NSLayoutConstraint.activate([
            bottomConstraintHight,
            bottomConstraintLow,
            sheetContainer.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            sheetContainer.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ])
    }
    
    func addCloseTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeWithAnimation))
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeWithAnimation))
        self.backgroundView?.addGestureRecognizer(tapGesture)
        self.viewContainer?.addGesture(closeGesture)
    }
    
    func startAnimation() {
        guard let parentView = self.viewContainer?.superview else { return }
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.backgroundView?.alpha = 0.5
                self?.viewContainer?.frame.origin = CGPoint(x: 0, y: -parentView.frame.height)
            }, completion: nil)
    }
}

// MARK: - SwipeDown
private extension SheetView {
    private var viewContainerHalfHeight: CGFloat {
        guard let optionalView = self.viewContainer else {
            return 0.0
        }
        return (optionalView.frame.height / 2)
    }
    
    @objc func panHandler(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self)
        switch sender.state {
        case .began:
            self.initialBottomConstraintValue = self.bottomConstraint?.constant ?? 0
        case .changed:
            let translation = sender.translation(in: self)
            self.bottomConstraint?.constant += translation.y
            sender.setTranslation(CGPoint.zero, in: self)
        case .ended:
            guard let bottomConstraintValue = self.bottomConstraint?.constant else {
                return
            }
            let distance = bottomConstraintValue - self.initialBottomConstraintValue
            let springVelocity = -1.0 * velocity.y / distance
            let springDampening: CGFloat = 0.6
            if bottomConstraintValue >= viewContainerHalfHeight {
                self.closeWithAnimation()
            } else {
                self.bounceBackWithDampening(springDampening, andVelocity: springVelocity)
            }
        default:
            break
        }
    }
    
    func addSwipeGesture() {
        if let closeView = self.viewContainer?.getCloseView() {
            closeView.addGestureRecognizer(self.panGesture)
        }
    }
    
    func bounceBackWithDampening(_ dampening: CGFloat, andVelocity velocity: CGFloat) {
        self.viewContainer?.superview?.layoutIfNeeded()
        UIView.animate(withDuration: self.animationDuration,
                        delay: 0.0,
                        usingSpringWithDamping: dampening,
                        initialSpringVelocity: velocity,
                        options: .curveEaseIn,
                        animations: {
            self.bottomConstraint?.constant = self.initialBottomConstraintValue
            self.viewContainer?.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}
