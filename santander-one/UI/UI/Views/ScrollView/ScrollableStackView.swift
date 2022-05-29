//
//  ScrollableStackView.swift
//  UI
//
//  Created by Juan Carlos López Robles on 12/5/19.
//

import UIKit

public class ScrollableStackView: UIView {
    public lazy var scrollView = UIScrollView()
    internal var view: UIView?
    
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setup(with view: UIView) {
        self.view = view
        self.view?.addSubview(scrollView)
        self.setupScrollView()
        self.setupStackView()
        self.backgroundColor = UIColor.bg
    }
    
    public func setScrollDelegate(_ delegate: UIScrollViewDelegate) {
        self.scrollView.delegate = delegate
    }
    
    private func setupScrollView() {
        self.scrollView.backgroundColor = .clear
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addScrollConstraints()
    }
    
    private func addScrollConstraints() {
        guard let view = self.view else { return }
        NSLayoutConstraint.activate([
            self.scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            self.topConstraint(),
            self.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    private func topConstraint() -> NSLayoutConstraint {
        guard let view = self.view else { return NSLayoutConstraint() }
        if #available(iOS 11.0, *) {
            return self.scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        } else {
            return self.scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        }
    }
    
    internal func setupStackView() {
        guard let view = self.view else { return }
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.stackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
            self.stackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            self.stackView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    public func enableScroll(isEnabled: Bool) {
        self.scrollView.isScrollEnabled = isEnabled
    }
    
    public func setBounce(enabled: Bool) {
        self.scrollView.bounces = enabled
    }
    
    /// This function gets the last view in the stack view arranged subviews,
    /// finds out its background color and updates the one in the container view.
    /// This should be used for coloring the container view when safe area is available.
    public func updateScrollBackground() {
        guard let lastView = stackView.arrangedSubviews.last else { return }
        self.view?.backgroundColor = lastView.backgroundColor
    }
    
    public func addArrangedSubview(_ view: UIView) {
        self.stackView.addArrangedSubview(view)
    }
    
    public func insetArrangedSubview(_ view: UIView, at index: Int) {
        self.stackView.insertArrangedSubview(view, at: index)
    }
    
    public func getArrangedSubviews() -> [UIView] {
        return self.stackView.arrangedSubviews
    }
    
    public func setSpacing(_ spacing: CGFloat) {
        self.stackView.spacing = spacing
    }
    
    public func setStackViewDistribution(_ distribution: UIStackView.Distribution) {
        self.stackView.distribution = distribution
    }
    
    public func setScrollInsets(_ insets: UIEdgeInsets) {
        self.scrollView.contentInset = insets
    }
    
    public func scrollRectToVisible(_ rect: CGRect, animated: Bool = true) {
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
    
    public func setContentOffset(_ point: CGPoint, animated: Bool) {
        self.scrollView.setContentOffset(point, animated: animated)
    }
    
    @available(iOS 11, *)
    public var frameLayoutGuide: UILayoutGuide {
        self.scrollView.frameLayoutGuide
    }
}
