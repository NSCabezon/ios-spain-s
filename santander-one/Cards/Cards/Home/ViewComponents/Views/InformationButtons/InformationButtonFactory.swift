//
//  InformationButtonFactory.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 11/4/19.
//

import Foundation
import UI

enum InformationButtonType {
    case cashDisposition
    case map
    case changePaymentMethod
    case generic(cardActionViewModel: CardActionViewModel)
    case settlementDetail
    case emptySettlementButtonView
    case loading
}

class InformationButtonFactory {
    
    static func getButtonsViewForViewModel(_ viewModel: CardViewModel) -> (left: UIView?, right: UIView?) {
        if viewModel.isCreditCard {
            return self.informationButtonsForCreditCard(viewModel)
        } else if viewModel.isDebitCard {
            return self.informationButtonsForDebitCard(viewModel)
        } else {
            return (nil, nil)
        }
    }
    
    static func informationButtonsForDebitCard(_ viewModel: CardViewModel) -> (left: UIView?, right: UIView?) {
        var genericButton: UIView?
        if let optionalActionViewModel = viewModel.cardActionViewModel {
            genericButton = InformationButtonFactory.getButtonOfType(.generic(cardActionViewModel: optionalActionViewModel), viewModel: viewModel)
        }
    let cashDispositionButtonView: UIView? = viewModel.isEnableCashWithDrawal ? InformationButtonFactory.getButtonOfType(.cashDisposition, viewModel: viewModel): nil

    let mapButton = InformationButtonFactory.getButtonOfType(.map, viewModel: viewModel)
        if viewModel.isMapEnable {
            return (mapButton, cashDispositionButtonView)
        }
        return (genericButton, cashDispositionButtonView)
    }
    
    static func informationButtonsForCreditCard(_ viewModel: CardViewModel) -> (left: UIView?, right: UIView?) {
        var genericButton: UIView?
        if let optionalActionViewModel = viewModel.cardActionViewModel {
            genericButton = InformationButtonFactory.getButtonOfType(.generic(cardActionViewModel: optionalActionViewModel), viewModel: viewModel)
        }
        let mapButton = InformationButtonFactory.getButtonOfType(.map, viewModel: viewModel)
        let secondaryButton = getSecondaryButton(viewModel)
        if viewModel.isMapEnable {
            return (mapButton, secondaryButton)
        }
        return (genericButton, secondaryButton)
    }
    
    /// information buttons factory
    /// - Parameter buttonType: type of button to return
    static func getButtonOfType(_ buttonType: InformationButtonType, viewModel: CardViewModel) -> UIView {
        let cardDisabled: Bool = viewModel.entity.isDisabled
        switch buttonType {
        case .cashDisposition:
            let button = CashDispositionButtonView()
            button.setDisabled(cardDisabled)
            return button
        case .changePaymentMethod:
            if viewModel.isPaymentMethodSuccess {
                let paymentMethodView = ChangePaymentMethodSuccessView()
                paymentMethodView.setPaymentMethodLabel(text: viewModel.paymentMethodDescription)
                paymentMethodView.setDisabled(cardDisabled || !viewModel.entity.isOwnerSuperSpeed)
                return paymentMethodView
            } else {
                let paymentMethodFailView = ChangePaymentMethodFailView()
                paymentMethodFailView.setDisabled(cardDisabled || !viewModel.entity.isOwnerSuperSpeed)
                return paymentMethodFailView
            }
        case .map:
            let button = MapButtonView()
            button.setDisabled(cardDisabled)
            return button
        case .generic(let actionViewModel):
            let genericActionButton = ActionButton()
            genericActionButton.grayAppearance()
            genericActionButton.setExtraLabelContent(actionViewModel.highlightedInfo)
            genericActionButton.setViewModel(actionViewModel)
            genericActionButton.addAction {
                actionViewModel.action?(actionViewModel.type, actionViewModel.entity)
            }
            genericActionButton.setIsDisabled(actionViewModel.isDisabled)
            return genericActionButton
        case .settlementDetail:
            let button = SettlementDetailButtonView()
            button.setDisabled(cardDisabled)
            button.setViewModel(viewModel)
            return button
        case .emptySettlementButtonView:
            return EmptySettlementButtonView()
        case .loading:
            var loadingButton = LoadingButtonView()
            loadingButton.setAccessibilityIdentifier(identifier: "cardHome_loadingButton")
            return loadingButton
        }
    }
}

private extension InformationButtonFactory {
    static func getSecondaryButton(_ viewModel: CardViewModel) -> UIView {
        if viewModel.showLoading && !viewModel.isDisabled {
            return InformationButtonFactory.getButtonOfType(.loading, viewModel: viewModel)
        }
        guard let cardDetail = viewModel.settlementDetailEntity else {
            return InformationButtonFactory.getButtonOfType(.changePaymentMethod, viewModel: viewModel)
        }
        guard cardDetail.emptyMovements == false else {
            return InformationButtonFactory.getButtonOfType(.emptySettlementButtonView, viewModel: viewModel)
        }
        guard cardDetail.errorCode == nil else {
            return InformationButtonFactory.getButtonOfType(.changePaymentMethod, viewModel: viewModel)
        }
        return InformationButtonFactory.getButtonOfType(.settlementDetail, viewModel: viewModel)
    }
}
