//
//  SavingAction.swift
//  SavingProducts

import Foundation
import UI
import CoreDomain
import CoreFoundationLib
import OpenCombine

public enum SavingActionState: State {
    case idle
    case actionSelected((SavingProductOptionType, SavingProductRepresentable))
}

public class SavingAction {
    public let savingProduct: SavingProductRepresentable
    public let type: SavingProductOptionType
    public let title: String
    public let iconName: String
    public let section: SavingsActionSection
    public let viewType: ActionButtonFillViewType?
    public var action: ((SavingProductOptionType, SavingProductRepresentable) -> Void)? {
        send(action:saving:)
    }

    public let isDisabled: Bool
    private let actionsSubject = CurrentValueSubject<SavingActionState, Never>(.idle)
    var actionState: AnyPublisher<SavingActionState, Never>

    public init(savingProduct: SavingProductRepresentable,
                type: SavingProductOptionType,
                title: String,
                iconName: String,
                section: SavingsActionSection,
                viewType: ActionButtonFillViewType? = nil,
                action: ((SavingProductRepresentable) -> Void)? = nil,
                isDisabled: Bool = false) {
        self.savingProduct = savingProduct
        self.section = section
        self.type = type
        self.title = title
        self.iconName = iconName
        self.viewType = viewType
        self.isDisabled = isDisabled
        self.actionState = actionsSubject.eraseToAnyPublisher()
    }
}

private extension SavingAction {
    func send(action: SavingProductOptionType, saving: SavingProductRepresentable) {
        actionsSubject.send(.actionSelected((action, saving)))
    }
}
