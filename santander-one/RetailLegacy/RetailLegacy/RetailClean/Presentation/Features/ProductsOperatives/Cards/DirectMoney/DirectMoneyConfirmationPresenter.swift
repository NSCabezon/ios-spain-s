//

import Foundation
import CoreFoundationLib

class DirectMoneyConfirmationPresenter: OperativeStepPresenter<DirectMoneyConfirmationViewController, VoidNavigator, DirectMoneyConfirmationPresenterProtocol> {
    
    var card: Card? {
        let directMoneyOperativeData: DirectMoneyCardOperativeData = containerParameter()
        return directMoneyOperativeData.card
    }
    
    // MARK: - Track
    override var screenId: String? {
        return TrackerPagePrivate.DirectMoneyConfirmation().page
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
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        view.navigationBarTitleLabel.accessibilityIdentifier = AccessibilityOthers.confirmationNavTitle.rawValue
        view.confirmButton.accessibilityIdentifier = AccessibilityOthers.confirmationBtn.rawValue
        let directMoneyOperativeData: DirectMoneyCardOperativeData = containerParameter()
        guard let amount = directMoneyOperativeData.amount else {
            return
        }
        let account = directMoneyOperativeData.account
        let iban = directMoneyOperativeData.iban
        let cardDetail = directMoneyOperativeData.cardDetail
        
        let cardSection = TableModelViewSection()
        let cardHeader = TitledTableModelViewHeader()
        cardHeader.title = stringLoader.getString("confirmation_text_originCard")
        cardSection.setHeader(modelViewHeader: cardHeader)
        let cardItem = CardConfirmationModelView(name: card?.getAliasUpperCase(), type: formattedSubtitle(), header: formattedTitle(), avaliable: card?.getAmountUI(), image: card?.buildImageRelativeUrl(true), dependencies: dependencies)
        cardSection.items = [cardItem]
        
        let directMoneySection = TableModelViewSection()
        let directMoneyHeader = TitledTableModelViewHeader()
        directMoneyHeader.title = stringLoader.getString("directMoney__text_directMoney")
        directMoneySection.setHeader(modelViewHeader: directMoneyHeader)
        
        let confirmationHeader = ConfirmationTableViewHeaderModel(amount.getFormattedAmountUI(), dependencies)
        directMoneySection.items.append(confirmationHeader)

        let accountItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_accounts"),
                                                          account?.getAliasAndInfo() ?? iban?.getAliasAndInfo(withCustomAlias: stringLoader.getString("generic_summary_associatedAccount").text) ?? "",
                                                          false,
                                                          dependencies)
        directMoneySection.items.append(accountItem)
        
        let holderItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_holder"),
                                                       cardDetail?.clientName.capitalized ?? "",
                                                       false,
                                                       dependencies)
        directMoneySection.items.append(holderItem)
        
        let date = dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy)
        let dateItem = ConfirmationTableViewItemModel(stringLoader.getString("directMoney_label_date"),
                                                      date ?? "",
                                                      true,
                                                      dependencies)
        directMoneySection.items.append(dateItem)
        view.sections = [cardSection, directMoneySection]
    }
}

extension DirectMoneyConfirmationPresenter: DirectMoneyConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let directMoneyOperativeData: DirectMoneyCardOperativeData = containerParameter()
        guard let amount: Amount = directMoneyOperativeData.amount, let card = directMoneyOperativeData.card else { return }
        
        let input = ValidateDirectMoneyUseCaseInput(card: card, amount: amount)
        let usecase = useCaseProvider.getValidateDirectMoneyUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let presenter = self else { return }
            presenter.hideLoading(completion: { [weak presenter] in
                guard let presenter = presenter else { return }
                let parameter: DirectMoneyCardOperativeData = presenter.containerParameter()
                parameter.directMoneyValidate = response.directMoneyValidate
                presenter.container?.saveParameter(parameter: parameter)
                presenter.container?.saveParameter(parameter: response.signature)
                presenter.container?.stepFinished(presenter: presenter)
            })
        }, onError: { [weak self] error in
            self?.hideLoading(completion: { [weak self] in
                self?.showError(keyDesc: error?.getErrorDesc())
            })
        })
    }
}
