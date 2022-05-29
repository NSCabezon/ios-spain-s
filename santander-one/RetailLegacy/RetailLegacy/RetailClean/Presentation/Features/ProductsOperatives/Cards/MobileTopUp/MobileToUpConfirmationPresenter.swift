import Foundation
import CoreFoundationLib

class MobileToUpConfirmationPresenter: OperativeStepPresenter<MobileToUpConfirmationViewController, VoidNavigator, MobileToUpConfirmationPresenterProtocol> {
    var card: Card? {
        guard let card: Card = container?.provideParameter() else {
            return nil
        }
        return card
    }
    override var screenId: String? {
        return TrackerPagePrivate.MobileRechargeConfirmation().page
    }
    
    private func formattedTitle() -> LocalizedStylableText? {
        guard let card = card else {
            return nil
        }
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }
    
    private func formattedSubtitle() -> LocalizedStylableText? {
        guard let card = card, let pan = card.getDetailUI().substring(card.getDetailUI().count - 4) else {
            return nil
        }
        let panDescription = "***" + pan
        let key: String
        if card.isPrepaidCard {
            key = "pg_label_ecashCard"
        } else if card.isCreditCard {
            key = "pg_label_creditCard"
        } else {
            key = "pg_label_debitCard"
        }
        return dependencies.stringLoader.getString(key, [StringPlaceholder(.value, panDescription)])
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.titleIdentifier = AccessibilityMobileRecharge.confirmationNavigationTitle.rawValue
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        guard let container = container else {
            return
        }
        
        let cardSection = TableModelViewSection()
        let cardHeader = TitledTableModelViewHeader()
        cardHeader.title = stringLoader.getString("confirmation_text_originCard")
        cardHeader.titleIdentifier = AccessibilityMobileRecharge.confirmationOrigenCardLabel.rawValue
        cardSection.setHeader(modelViewHeader: cardHeader)
        let cardSectionIdentifiers = CardConfirmationModelViewIdentifiers(titleLabelIdentifier: AccessibilityMobileRecharge.confirmationCardName.rawValue,
                                                         subtitleLabelIdentifier: AccessibilityMobileRecharge.confirmationCardNumber.rawValue,
                                                         rightTitleLabelIdentifier: AccessibilityMobileRecharge.confirmationCardRightLabel.rawValue,
                                                         rightSubtitleLabelIdentifier: AccessibilityMobileRecharge.confirmationCardAmount.rawValue,
                                                         cardImageIdentifier: AccessibilityMobileRecharge.confirmationCardImage.rawValue)
        let cardItem = CardConfirmationModelView(name: card?.getAliasUpperCase(), type: formattedSubtitle(), header: formattedTitle(), avaliable: card?.getAmountUI(), image: card?.buildImageRelativeUrl(true), dependencies: dependencies, identifiers: cardSectionIdentifiers)
        cardSection.items = [cardItem]

        let rechargeSection = TableModelViewSection()
        let rechargeHeader = TitledTableModelViewHeader()
        rechargeHeader.title = stringLoader.getString("confirmation_text_rechange")
        rechargeHeader.titleIdentifier = AccessibilityMobileRecharge.confirmationRechargeTitle.rawValue
        rechargeSection.setHeader(modelViewHeader: rechargeHeader)
        let phone: MobilePhoneNumber = container.provideParameter()
        let mobile: String = phone.number
        let date = dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy)
        let amount: Amount = container.provideParameter()
        let mobileOperator: MobileOperator = container.provideParameter()
        let confirmationHeader = ConfirmationTableViewHeaderModel(amount.getFormattedAmountUI(), dependencies)
        rechargeSection.items.append(confirmationHeader)
        let operatorItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_operator"),
                                                               mobileOperator.name ?? "",
                                                               false,
                                                               dependencies,
                                                               descriptionIdentifier: AccessibilityMobileRecharge.confirmationItemOperatorLabel.rawValue,
                                                               valueIdentifier: AccessibilityMobileRecharge.confirmationItemOperatorValue.rawValue)
        rechargeSection.items.append(operatorItem)
        let phoneItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_numberPhone"),
                                                                 mobile.spainTlfFormatted(),
                                                                 false,
                                                                 dependencies,
                                                                 descriptionIdentifier: AccessibilityMobileRecharge.confirmationItemPhoneLabel.rawValue,
                                                                 valueIdentifier: AccessibilityMobileRecharge.confirmationItemPhoneValue.rawValue)
        rechargeSection.items.append(phoneItem)
        let dateItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_date"),
                                                  date ?? "",
                                                  true,
                                                  dependencies,
                                                  descriptionIdentifier: AccessibilityMobileRecharge.confirmationItemDateLabel.rawValue,
                                                  valueIdentifier: AccessibilityMobileRecharge.confirmationItemDateValue.rawValue)
        rechargeSection.items.append(dateItem)
        view.sections = [cardSection, rechargeSection]
    }
}

extension MobileToUpConfirmationPresenter: MobileToUpConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        guard let card = card else {
            return
        }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidateMobileTopUpUseCaseInput(card: card)
        let usecase = useCaseProvider.validateMobileTopUpUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let presenter = self else { return }
            presenter.hideLoading(completion: {
                if let signatureAndToken = response.validateMobileRecharge.signatureWithToken {
                    presenter.container?.saveParameter(parameter: signatureAndToken)
                    presenter.container?.stepFinished(presenter: presenter)
                } else {
                     presenter.showError(keyDesc: nil)
                }
            })
            
        }, onError: { [weak self] error in
            guard let presenter = self else { return }
            presenter.hideLoading(completion: {
                presenter.showError(keyDesc: error?.getErrorDesc())
            })
        })
    }
}
