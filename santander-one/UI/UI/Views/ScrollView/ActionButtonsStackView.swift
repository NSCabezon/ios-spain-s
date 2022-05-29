import UIKit
import CoreFoundationLib

public final class ActionButtonsStackView<Button: ActionButtonViewModelProtocol>: UIStackView {
    // MARK: - Public
    
    var isDragEnable = false
    weak var delegate: DragButtonDelegate?
    private var interactionDisabled = false
    
    public func addActions(_ actions: [Button], sectionTitle: String?, usingStyle style: ActionButtonStyle? = nil, delegate: DragButtonDelegate? = nil) {
        let onlyEnabledActions: [Button] = actions.filter({ !$0.isDisabled })
        guard !onlyEnabledActions.isEmpty else { return }
        addSectionTitle(sectionTitle: sectionTitle, usingStyle: style)
        addActions(actions, usingStyle: style, delegate: delegate)
    }
    
    public func addActions(_ actions: [Button], usingStyle style: ActionButtonStyle? = nil, delegate: DragButtonDelegate? = nil) {
        let onlyEnabledActions: [Button] = actions.filter({ !$0.isDisabled })
        guard !onlyEnabledActions.isEmpty else { return }
        let stackView = self.horizontalStackView()
        let actionsToAdd = Array(onlyEnabledActions.prefix(self.colums))
        
        for index in 0 ..< actionsToAdd.count {
            let button = self.actionButton(for: actionsToAdd[index], delegate: delegate)
            if let style = style { button.setAppearance(withStyle: style) }
            button.checkEnabledStyle()
            if button.isUserInteractionEnabled {
                stackView.addArrangedSubview(button)
            }
        }
        
        guard actionsToAdd.count == self.colums else {
            // Adds some empty views to keep the proportion of each element inside the stackview
            let emptyViewsNeeded = self.colums - actionsToAdd.count
            for _ in 0 ..< emptyViewsNeeded {
                stackView.addArrangedSubview(emptyView())
            }
            return self.addArrangedSubview(stackView)
        }
        
        self.addArrangedSubview(stackView)
        // Calls again to add the actions by dropping the first `colums`
        self.addActions(Array(onlyEnabledActions.dropFirst(self.colums)), usingStyle: style, delegate: delegate)
    }
    
    public func setAlphaArrangedSubViews(_ alpha: CGFloat) {
        self.arrangedSubviews.forEach { $0.alpha = alpha }
    }
    
    public func setDragEnabled(_ enabled: Bool) {
        self.isDragEnable = enabled
        guard enabled else { return }
        let allSubviews = arrangedSubviews.flatMap { $0.getAllSubviews() }
        let dragButtons = allSubviews.filter { $0 is DragButton }
        dragButtons.forEach { (button) in
            (button as? DragButton)?.configureDraggable(delegate: delegate)
            (button as? DragButton)?.enableDrag()
        }
    }
    
    public func setAlphaArrangedSubViewsAnimated(alpha: CGFloat, delay: Double, completion: (() -> Void)? = nil) {
        let newArray = self.arrangedSubviews
        var totalDelay = delay
        
        newArray.forEach { (stack) in
            UIView.animate(withDuration: delay, delay: totalDelay, options: [], animations: {
                stack.alpha = alpha
            }, completion: { _ in
                completion?()
            })
            totalDelay += delay
        }
    }
    
    // MARK: - Private
    
    private let colums = 4
    
    private func horizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private func emptyView() -> UIView {
        return UIView()
    }
    
    @objc private func performAction(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? ActionButton,
            let viewModel = button.getViewModel() as? Button,
            !isDragEnable,
            button.extraTopLabel.text != localized("generic_label_shortly"),
            !interactionDisabled
            else { return }
        viewModel.action?(viewModel.actionType, viewModel.entity)
        disableMultitouchInteractionTemporarily()
    }
    
    private func actionButton<Button: ActionButtonViewModelProtocol>(for action: Button, delegate: DragButtonDelegate?) -> ActionButton {
        self.delegate = delegate
        let actionButton = DragButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setViewModel(action, isDragDisabled: action.isDisabled)
        actionButton.setExtraLabelContent(action.highlightedInfo)
        actionButton.addSelectorAction(target: self, #selector(performAction(_:)))
        actionButton.setIsDisabled(action.isDisabled)
        actionButton.heightAnchor.constraint(equalToConstant: 71).isActive = true
        actionButton.setDragDisabled(action.isDragDisabled)
        actionButton.accessibilityIdentifier = action.accessibilityIdentifier
        return actionButton
    }
    
    private func addSectionTitle(sectionTitle: String?, usingStyle style: ActionButtonStyle? = nil) {
        guard let sectionTitle = sectionTitle, !sectionTitle.isEmpty else { return }
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 24))
        label.textAlignment = .left
        label.text = sectionTitle
        label.font = UIFont.santander(family: .headline, type: .bold, size: 15)
        label.textColor = style?.textColor
        self.addArrangedSubview(label)
    }
    
    private func disableMultitouchInteractionTemporarily() {
        interactionDisabled = true
        Async.after(seconds: 0.5) { [weak self] in
            self?.interactionDisabled = false
        }
    }
}
