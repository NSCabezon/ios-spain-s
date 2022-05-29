//
//  CardTransactionDetailActionFactory.swift
//  Cards
//
//  Created by Carlos Monfort Gómez on 22/11/2019.
//

import Foundation
import CoreFoundationLib

// MARK: - Legacy
public protocol CardTransactionDetailActionsEnabledModifierProtocol {
    var shareAction: Bool { get }
    var directMoneyAction: Bool { get }
}

class CardTransactionDetailActionFactory {
    
    static func getCardTransactionDetailActionForViewModel(viewModel: OldCardTransactionDetailViewModel, _ entity: CardEntity,
                                                           dependenciesResolver: DependenciesResolver,
                                                           action: @escaping (OldCardActionType, CardEntity) -> Void) -> [CardActionViewModel] {
        if entity.isCreditCard || entity.isDebitCard {
            return makeCardTransactionDetailActions(viewModel: viewModel, action, dependenciesResolver: dependenciesResolver, entity: entity)
        } else if entity.isPrepaidCard {
            return makePrepaidCardTransactionDetailActions(viewModel: viewModel, action, dependenciesResolver: dependenciesResolver, entity: entity)
        } else {
            return []
        }
    }
    
    static func makeCardTransactionDetailActions(viewModel: OldCardTransactionDetailViewModel,
                                                 _ action: @escaping (OldCardActionType, CardEntity) -> Void,
                                                 dependenciesResolver: DependenciesResolver,
                                                 entity: CardEntity) -> [CardActionViewModel] {
        let builder = CardTransactionDetailActionBuilder(entity: entity)
        let cardTransactionDetailActionModifier = dependenciesResolver.resolve(forOptionalType: CardTransactionDetailActionFactoryModifierProtocol.self)
        let isActionDisabled = entity.isInactive
        let isShareEnabled = dependenciesResolver.resolve(forOptionalType: CardTransactionDetailActionsEnabledModifierProtocol.self)?.shareAction ?? !isActionDisabled
        
        if let modifier = cardTransactionDetailActionModifier, let customActions = modifier.getCustomActions(for: entity, forTransaction: viewModel.transaction) {
            customActions.forEach { customAction in
                switch customAction {
                case .onCard: builder.addOn(action)
                case .offCard: builder.addOff(action)
                case .enable: builder.addEnable(action)
                case .share: builder.addShare(viewModel: viewModel, action, !isShareEnabled)
                case .pdfDetail: builder.addPDFDetail(action)
                default: break
                }
            }
            return builder.build()
        }
        if entity.isInactive {
            builder.addEnable(action)
        } else if entity.isDisabled {
            builder.addOn(action)
        }
        if viewModel.isSplitExpensesOperativeEnabled, let modifier = cardTransactionDetailActionModifier {
            builder.addDivideCustom(cardTransactionDetailActionModifier: modifier,
                                    viewModel: viewModel,
                                    action: action,
                                    isActionDisabled: isActionDisabled)
        }
        if !entity.isDisabled {
            builder.addOff(action)
        }
        if let offer = fraudOffer(dependenciesResolver: dependenciesResolver) {
            builder.addFraud(offer: offer, action, isActionDisabled)
        }
        builder.addShare(viewModel: viewModel, action, !isShareEnabled)
        if let modifier = cardTransactionDetailActionModifier, modifier.addPDFDetail(transaction: viewModel.transaction) {
            builder.addPDFDetail(action)
        }
        return builder.build()
    }
    
    static func makePrepaidCardTransactionDetailActions(viewModel: OldCardTransactionDetailViewModel,
                                                        _ action: @escaping (OldCardActionType, CardEntity) -> Void,
                                                        dependenciesResolver: DependenciesResolver,
                                                        entity: CardEntity) -> [CardActionViewModel] {
        
        let builder = CardTransactionDetailActionBuilder(entity: entity)
        let cardTransactionDetailActionModifier = dependenciesResolver.resolve(forOptionalType: CardTransactionDetailActionFactoryModifierProtocol.self)
        let isActionDisabled = entity.isInactive || entity.isDisabled
        if viewModel.isSplitExpensesOperativeEnabled, let modifier = cardTransactionDetailActionModifier {
            builder.addDivideCustom(cardTransactionDetailActionModifier: modifier,
                                    viewModel: viewModel,
                                    action: action,
                                    isActionDisabled: isActionDisabled)
        }
        builder.addPrepaid(action, isActionDisabled)
        if let offer = fraudOffer(dependenciesResolver: dependenciesResolver) {
            builder.addFraud(offer: offer, action, isActionDisabled)
        }
        if let shareAction = dependenciesResolver.resolve(forOptionalType: CardTransactionDetailActionsEnabledModifierProtocol.self)?.shareAction {
            builder.addShare(viewModel: viewModel, action, !shareAction)
        } else {
            builder.addShare(viewModel: viewModel, action, isActionDisabled)
        }
        return builder.build()
    }
    
    private static func fraudOffer(dependenciesResolver: DependenciesResolver) -> OfferEntity? {
        guard let offer = dependenciesResolver.resolve(for: PullOffersInterpreter.self).getValidOffer(offerId: "REPORTAR_FRAUDE") else {
            return nil
        }
        return OfferEntity(offer)
    }
}
