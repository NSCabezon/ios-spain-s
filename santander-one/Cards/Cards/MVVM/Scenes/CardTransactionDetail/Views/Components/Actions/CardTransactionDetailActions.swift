//
//  CardTransactionDetailActions.swift
//  Cards
//
//  Created by Hernán Villamil on 6/4/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit
import UI

public enum CardTransactionDetailActionsState: State {
    case idle
    case items([CardActions])
}

final class CardTransactionDetailActions: UIView {
    private var actionButtons: [ActionButton] = []
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
        return stackView
    }()
    private var subscriptions = Set<AnyCancellable>()
    private lazy var state: AnyPublisher<CardTransactionDetailActionsState, Never> = {
        stateSubject.eraseToAnyPublisher()
    }()
    public let stateSubject = PassthroughSubject<CardTransactionDetailActionsState, Never>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

private extension CardTransactionDetailActions {
    func commonInit() {
        setup()
        bind()
    }
    
    func setup() {
        self.addSubview(stackView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 19),
            self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 20),
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            self.rightAnchor.constraint(equalTo: self.stackView.rightAnchor, constant: 10)
        ])
    }
    
    func setActionsForItems(_ items: [CardActions]) {
        items.forEach { (item) in
            let cardAction = makeCardTransactionDetailActionForViewModel(item)
            self.actionButtons.append(cardAction)
        }
        addActionButtonsToStackView()
    }
    
    func addActionButtonsToStackView() {
        self.actionButtons.forEach {
            self.stackView.addArrangedSubview($0)
        }
    }
    
    func makeCardTransactionDetailActionForViewModel(_ item: CardActions) -> ActionButton {
        let action = ActionButton()
        action.setExtraLabelContent(item.highlightedInfo)
        action.setViewModel(item)
        action.addSelectorAction(target: self, #selector(performCardTransactionDetailAction))
        action.setIsDisabled(item.isDisabled)
        action.accessibilityIdentifier = item.accessibilityIdentifier
        return action
    }
    
    @objc func performCardTransactionDetailAction(_ gesture: UITapGestureRecognizer) {
        guard let actionButton = gesture.view as? ActionButton else { return }
        guard let button = actionButton.getViewModel() as? CardActions else { return }
        button.action?(button.type, button.entity)
    }
    
    public func removeSubviews() {
        self.actionButtons.removeAll()
        for view in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

private extension CardTransactionDetailActions {
    func bind() {
        bindItems()
    }
    
    func bindItems() {
        state
            .case(CardTransactionDetailActionsState.items)
            .sink { [unowned self] items in
                self.setActionsForItems(items)
            }.store(in: &subscriptions)
    }
}
