//
//  CardTransactionActionBuilder.swift
//  Pods
//
//  Created by Hernán Villamil on 22/4/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public typealias CardTransactionAction = ((CardActionType, CardRepresentable) -> Void)?
public typealias AddFraudInput = (offer: OfferRepresentable?, isDisabled: Bool)
public typealias AddDivideInput = (splitableItem: SplitableCardTransaction,
                                   customType: ActionButtonFillViewType,
                                   isDisabled: Bool)
public enum CardTransactionActionBuilderState: State {
    case addOn
    case addOff
    case addEnable
    case addShare(Bool)
    case addFraud(AddFraudInput)
    case addPrepaid(Bool)
    case addCustom
    case addDivideCustom(AddDivideInput)
    case addPDFDetail
}

public final class CardTransactionActionBuilder {
    private let card: CardRepresentable
    private var action: CardTransactionAction
    private var actions: [CardActions] = []
    private var subscriptions: Set<AnyCancellable> = []
    private var state: AnyPublisher<CardTransactionActionBuilderState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    public let stateSubject = PassthroughSubject<CardTransactionActionBuilderState, Never>()
    
    public init(card: CardRepresentable, action: CardTransactionAction) {
        self.card = card
        self.action = action
        bind()
    }
    
    func build() -> [CardActions] {
        return actions
    }
}

// MARK: - Bind
private extension CardTransactionActionBuilder {
    func bind() {
        bindAddOn()
        bindAddOff()
        bindAddEnable()
        bindAddShare()
        bindAddFraud()
        bindAddPrepaid()
        bindAddCustom()
        bindAddPDFDetail()
        bindAddDivideCustom()
    }
    
    func bindAddOn() {
        state
            .case(.addOn)
            .sink { [unowned self] _ in
                let actionButton = DefaultActionButtonViewModel(
                    title: "frequentOperative_label_turnOn",
                    imageKey: "icnOn",
                    titleAccessibilityIdentifier: AccessibilityOtherOperatives.btnCardOn.rawValue,
                    imageAccessibilityIdentifier: "icnOn")
                let action = CardActions(card: self.card,
                                         type: .onCard,
                                         viewType: .defaultButton(actionButton))
                self.actions.append(action)
            }.store(in: &subscriptions)
    }
    
    func bindAddOff() {
        state
            .case(.addOff)
            .sink { [unowned self] _ in
                let actionButton = DefaultActionButtonViewModel(
                    title: "transaction_buttonOption_cardOff",
                    imageKey: "icnOff",
                    titleAccessibilityIdentifier: AccessibilityOtherOperatives.btnCardOff.rawValue,
                    imageAccessibilityIdentifier: "icnOff")
                let action = CardActions(card: self.card,
                                         type: .offCard,
                                         viewType: .defaultButton(actionButton))
                self.actions.append(action)
            }.store(in: &subscriptions)
     }
    
    func bindAddEnable() {
        state
            .case(.addEnable)
            .sink { [unowned self] _ in
                let action = CardActions(card: self.card,
                                         type: .enable)
                self.actions.append(action)
            }.store(in: &subscriptions)
     }
    
    func bindAddShare() {
        state
            .case(CardTransactionActionBuilderState.addShare)
            .sink { [unowned self] isDisabled in
                let sharableCard = ShareableCard(card: self.card)
                let action = CardActions(card: self.card,
                                         type: .share(sharableCard),
                                         isDisabled: isDisabled)
                self.actions.append(action)
            }.store(in: &subscriptions)
     }
    
    func bindAddFraud() {
        state
            .case(CardTransactionActionBuilderState.addFraud)
            .sink { [unowned self] input in
                let action = CardActions(card: self.card,
                                         type: .fraud(input.offer),
                                         isDisabled: input.isDisabled)
                self.actions.append(action)
            }.store(in: &subscriptions)
     }
    
    func bindAddPrepaid() {
        state
            .case(CardTransactionActionBuilderState.addPrepaid)
            .sink { [unowned self] isDisabled in
                let action = CardActions(card: self.card,
                                         type: .chargePrepaid,
                                         isDisabled: isDisabled)
                self.actions.append(action)
            }.store(in: &subscriptions)
     }
    
    func bindAddCustom() {
        state
            .case(.addCustom)
            .sink { [unowned self] _ in
                let action = CardActions(card: self.card,
                                         type: .onCard)
                self.actions.append(action)
            }.store(in: &subscriptions)
     }
    
    func bindAddPDFDetail() {
        state
            .case(.addPDFDetail)
            .sink { [unowned self] _ in
                let action = CardActions(card: self.card,
                                         type: .pdfDetail)
                self.actions.append(action)
            }.store(in: &subscriptions)
     }
    
    func bindAddDivideCustom() {
        state
            .case(CardTransactionActionBuilderState.addDivideCustom)
            .sink { [unowned self] input in
                let action = CardActions(card: self.card,
                                         type: .divide(input.splitableItem),
                                         viewType: input.customType,
                                         isDisabled: input.isDisabled)
                self.actions.append(action)
            }.store(in: &subscriptions)
    }
}
