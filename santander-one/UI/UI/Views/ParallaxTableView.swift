//
//  ParalaxUITableView.swift
//  UI
//
//  Created by Juan Carlos López Robles on 10/10/19.
//

import UIKit

public class ParallaxTableView: UITableView {
    private var expandedHeight: CGFloat = 300
    private var collapsedHeight: CGFloat = 60
    private var expandedView: UIView!
    private var collapsedView: UIView!
    private var owner: UIView!
    private var parallaxHeightConstraint: NSLayoutConstraint!
    
    convenience init(owner: UIView) {
        self.init(frame: owner.frame, style: .plain)
        self.owner = owner
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setOwnerView(_ view: UIView) {
        self.owner = view
    }
    
    public func setExpandedHeight(_ height: CGFloat) {
        self.expandedHeight = height
    }
    
    public func setCollapsedHeight(_ height: CGFloat) {
        self.collapsedHeight = height
    }
    
    public func setExpandedView(_ view: UIView) {
        self.expandedView = view
        self.owner.addSubview(expandedView)
    }
    
    public func setCollapsedView(_ view: UIView) {
        self.collapsedView = view
    }
    
    public func setParallaxHeightConstraint(_ heightConstraint: NSLayoutConstraint) {
        self.parallaxHeightConstraint = heightConstraint
    }
    
    public func disableDragInteraction() {
        self.isScrollEnabled = false
    }
      
    public func enableDragInteraction() {
        self.isScrollEnabled = true
    }
}

extension ParallaxTableView {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.updateParallaxHeight()
        self.addParallaxViewForHeight()
        self.updateParalaxViewAlphaForHeight()
        self.adjustScrollForPoint(scrollView.contentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.updateParallaxHeight()
        self.adjustParallaxViewForHeight()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateParallaxHeight()
        self.adjustParallaxViewForHeight()
    }
    
    private func updateParallaxHeight() {
        let height = parallaxHeightConstraint.constant - self.contentOffset.y
        if height >= collapsedHeight && height <= expandedHeight {
            self.contentOffset = CGPoint.zero
        }
        self.setAnimatedParallaxHeight(height)
    }
    
    private func setAnimatedParallaxHeight(_ height: CGFloat) {
            self.parallaxHeightConstraint.constant =
                min(self.expandedHeight, max(self.collapsedHeight, height))
    }
    
    private func addParallaxViewForHeight() {
        self.addCorrespondingViewForHeight()
        self.removeExpandedViewIfNeed()
        self.removeCollapsedViewIfNeed()
    }
    
    private func addCorrespondingViewForHeight() {
        let percentage = getExpandedHeightPercentage()
        if percentage > 35 {
            addExpandedView()
        } else {
            addCollapsedView()
        }
    }
    
    private func removeExpandedViewIfNeed() {
        let percentage = getExpandedHeightPercentage()
        if percentage < 30 {
            self.expandedView.removeFromSuperview()
        }
    }
    
    private func removeCollapsedViewIfNeed() {
        let percentage = getExpandedHeightPercentage()
        if percentage > 70 {
            self.collapsedView.removeFromSuperview()
        }
    }
    
    private func updateParalaxViewAlphaForHeight() {
        self.updateExpandedViewAlphaForHeight()
        self.updateCollapsedViewAlphaForHeight()
    }
    
    private func updateExpandedViewAlphaForHeight() {
        let percentage = getExpandedHeightPercentage()
        let decimalPercentage = percentage / 100
        if percentage == 100 {
            self.expandedView.alpha = decimalPercentage
        } else {
            self.expandedView.alpha = decimalPercentage - 0.3
        }
    }
    
    private func updateCollapsedViewAlphaForHeight() {
        let percentage = (collapsedHeight * 100)  / self.parallaxHeightConstraint.constant
        let decimalPercentage = percentage / 100
        if percentage == 100 {
            self.collapsedView.alpha = decimalPercentage
        } else {
            self.collapsedView.alpha = decimalPercentage - 0.25
        }
    }
    
    private func getExpandedHeightPercentage() -> CGFloat {
        let percentage = (self.parallaxHeightConstraint.constant * 100)  / expandedHeight
        return round(percentage)
    }
    
    private func addCollapsedView() {
        self.collapsedView.frame.size.height = self.parallaxHeightConstraint.constant
        self.owner.addSubview(self.collapsedView)
    }
    
    private func addExpandedView() {
        self.owner.addSubview(expandedView)
        self.expandedView.setNeedsLayout()
    }
    
    private func adjustScrollForPoint(_ point: CGPoint) {
        if point.y < 0 {
            self.contentOffset = .zero
        }
    }
    
    private func adjustParallaxViewForHeight() {
        let percentage = getExpandedHeightPercentage()
        if percentage > 35 {
            self.resetToExpandedView()
        } else {
            self.resetToCollapsedView()
        }
    }
    
    private func resetToExpandedView() {
        self.parallaxHeightConstraint.constant = self.expandedHeight
        guard let headerView = self.tableHeaderView else { return }
        self.scrollRectToVisible(headerView.frame, animated: true)
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.updateExpandedViewAlphaForHeight()
            self?.layoutIfNeeded()
        }
    }
    
    private func resetToCollapsedView() {
        self.parallaxHeightConstraint.constant = self.collapsedHeight
        self.collapsedView.frame.size.height = self.collapsedHeight
        UIView.animate(withDuration: 0.5) {  [weak self] in
            self?.updateCollapsedViewAlphaForHeight()
            self?.layoutIfNeeded()
        }
    }
}
