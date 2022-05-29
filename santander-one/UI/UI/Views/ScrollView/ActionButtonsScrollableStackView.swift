//
//  OtherOperativesScrollableStackView.swift
//  Account
//
//  Created by Jose Carlos Estela Anguita on 15/12/2019.
//

import Foundation
import UIKit
import CoreFoundationLib

public final class ActionButtonsScrollableStackView<Button: ActionButtonViewModelProtocol>: ScrollableStackView {
    override public func setup(with view: UIView) {
        super.setup(with: view)
        self.stackView.spacing = 0
        self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        self.stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    // MARK: - Public
    
    public func removeActions() {
        stackView.removeAllArrangedSubviews()
    }
    
    public func addActions(_ actions: [Button], sectionTitle: String, sectionTitleIdentifier: String? = nil, usingStyle style: ActionButtonStyle? = nil, allowDisable: Bool = false) {
        let onlyEnabledActions: [Button] = allowDisable ?
            actions : actions.filter({ !$0.isDisabled })
        addSectionTitle(onlyEnabledActions,
                        sectionTitle: sectionTitle,
                        sectionTitleIdentifier: sectionTitleIdentifier,
                        usingStyle: style)
        guard actions.count > 0 else { return }
        let stackView = self.horizontalStackView()
        createNewLine(stackView,
                      from: onlyEnabledActions,
                      usingStyle: style,
                      afterAddingBlock: {
                        if onlyEnabledActions.count > self.colums && sectionTitle.isEmpty {
                            stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 6, right: 0)
                        } else if onlyEnabledActions.count <= self.colums {
                            stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)
                        }
                      })
        
        self.addArrangedSubview(stackView)
        // Calls again to add the actions by dropping the first `colums`
        let remainActions = onlyEnabledActions.dropFirst(self.colums)
        guard remainActions.count > 0 else { return }
        self.addActions(Array(remainActions),
                        sectionTitle: "",
                        usingStyle: style,
                        allowDisable: allowDisable)
    }
    
    public func setAlphaArrangedSubViews(_ alpha: CGFloat) {
        stackView.arrangedSubviews.forEach { $0.alpha = alpha }
    }
    
    public func setAlphaArrangedSubViewsAnimated(alpha: CGFloat, delay: Double) {
        let newArray = stackView.arrangedSubviews.chunked(by: colums)
        var totalDelay = delay
        
        newArray.forEach { (views) in
            views.forEach { (view) in
                UIView.animate(withDuration: delay, delay: totalDelay, options: [], animations: {
                    view.alpha = alpha
                }, completion: nil)
                totalDelay += delay
            }
        }
    }
    
    // MARK: - Private
    
    private let colums = 4
    
    private func horizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }
    
    @objc private func performAction(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? ActionButton, let viewModel = button.getViewModel() as? Button else { return }
        viewModel.action?(viewModel.actionType, viewModel.entity)
    }
    
    private func actionButton<Button: ActionButtonViewModelProtocol>(for action: Button) -> ActionButton {
        let actionButton = ActionButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setViewModel(action, isDragDisabled: action.isDisabled)
        actionButton.setExtraLabelContent(action.highlightedInfo)
        actionButton.addSelectorAction(target: self, #selector(performAction(_:)))
        actionButton.setIsDisabled(action.isDisabled)
        actionButton.heightAnchor.constraint(equalToConstant: 72).isActive = true
        actionButton.accessibilityIdentifier = action.accessibilityIdentifier
        return actionButton
    }
    
    private func emptyView() -> UIView {
        return UIView()
    }
    
    private func addSectionTitle(_ actions: [Button], sectionTitle: String, sectionTitleIdentifier: String? = nil, usingStyle style: ActionButtonStyle? = nil) {
        if actions.count > 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.stackView.bounds.width, height: 24))
            label.textAlignment = .left
            label.text = sectionTitle
            label.font = UIFont.santander(family: .headline, type: .bold, size: 15)
            label.textColor = style?.textColor
            label.accessibilityIdentifier = sectionTitleIdentifier
            self.stackView.addArrangedSubview(label)
            
            label.isHidden = (sectionTitle == "") ? true : false
        }
    }
    
    private func completeLine(_ stackView: UIStackView, withEmptyViews emptyViewsNeeded: Int) {
        (0 ..< emptyViewsNeeded).forEach { _ in stackView.addArrangedSubview(emptyView()) }
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    private func createNewLine(_ stackView: UIStackView,
                               from actions: [Button],
                               usingStyle style: ActionButtonStyle?,
                               afterAddingBlock: () -> Void) {
        let actionsToAdd = Array(actions.prefix(self.colums))
        actionsToAdd.forEach { (action) in
            let button = self.actionButton(for: action)
            if let style = style { button.setAppearance(withStyle: style) }
            button.checkEnabledStyle()
            stackView.addArrangedSubview(button)
        }
        if actionsToAdd.count == self.colums {
            stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 6, right: 0)
        }
        guard actionsToAdd.count == self.colums else {
            // Adds some empty views to keep the proportion of each element inside the stackview
            let emptyViewsNeeded = self.colums - actionsToAdd.count
            completeLine(stackView, withEmptyViews: emptyViewsNeeded)
            return afterAddingBlock()
        }
        afterAddingBlock()
    }
}
