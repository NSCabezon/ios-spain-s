import Foundation

class CardLimitManagementConfirmationPresenter: OperativeStepPresenter<OperativeConfirmationViewController, Void, OperativeConfirmationPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var operativeData: CardLimitManagementOperativeData {
        return containerParameter()
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.ModifyCardLimitsConfirmation().page
    }
    
    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        view.update(title: dependencies.stringLoader.getString("genericToolbar_title_confirmation"))
        view.updateButton(title: stringLoader.getString("generic_button_confirm"))
        self.view.sections = [
            cardSection(),
            limitsSection()
        ]
    }
    
    // MARK: - Private methods
    
    private func cardSection() -> TableModelViewSection {
        guard let card = operativeData.productSelected else { return TableModelViewSection() }
        let cardSection = TableModelViewSection()
        let cardHeader = TitledTableModelViewHeader()
        cardHeader.title = stringLoader.getString("confirmation_item_card")
        cardHeader.titleIdentifier = "cardLimitConfirmation_cardTitle"
        cardSection.setHeader(modelViewHeader: cardHeader)
        let cardItem = CardConfirmationModelView(
            name: card.getAliasUpperCase(),
            type: formattedSubtitle(card: card),
            header: formattedTitle(card: card),
            avaliable: card.getAmountUI(),
            image: card.buildImageRelativeUrl(true),
            dependencies: dependencies,
            identifiers: CardConfirmationModelViewIdentifiers(titleLabelIdentifier: "cardLimitConfirmation_cardHeader_title", subtitleLabelIdentifier: "cardLimitConfirmation_cardHeader_subtitle", rightTitleLabelIdentifier: "cardLimitConfirmation_cardHeader_rightTitle", rightSubtitleLabelIdentifier: "cardLimitConfirmation_cardHeader_rightSubtitle", cardImageIdentifier: "cardLimitConfirmation_cardHeader_image")
        )
        cardSection.items = [cardItem]
        return cardSection
    }
    
    private func limitsSection() -> TableModelViewSection {
        let section = TableModelViewSection()
        let header = TitledTableModelViewHeader()
        header.titleIdentifier = "cardLimitConfirmation_cardLimit"
        header.title = stringLoader.getString("limitsModifyCard_label_newLimits")
        section.setHeader(modelViewHeader: header)
        switch operativeData.cardLimit {
        case .credit(let daily)?:
            let dailyHeader = ConfirmationTableViewHeaderModel(daily.getAbsFormattedAmountUI(), description: dependencies.stringLoader.getString("limitsModifyCard_label_dailyLimitAtm").text, type: .alone, suffixIdentifier: "cardLimitConfirmation_dailyLimit", dependencies)
            section.add(item: dailyHeader)
        case .debit(let daily, let atm)?:
            let shoppingHeader = ConfirmationTableViewHeaderModel(daily.getAbsFormattedAmountUI(), description: dependencies.stringLoader.getString("limitsModifyCard_label_dailyLimitShopping").text, type: .last, suffixIdentifier: "cardLimitConfirmation_shoppingLimit", dependencies)
            let atmHeader = ConfirmationTableViewHeaderModel(atm.getAbsFormattedAmountUI(), description: dependencies.stringLoader.getString("limitsModifyCard_label_dailyLimitAtm").text, type: .firstWithSeparator, suffixIdentifier: "cardLimitConfirmation_atmLimit", dependencies)
            section.add(item: atmHeader)
            section.add(item: shoppingHeader)
        case .none:
            return section
        }
        return section
    }
    
    private func formattedTitle(card: Card) -> LocalizedStylableText? {
        if card.isPrepaidCard {
            return dependencies.stringLoader.getString("pg_label_balanceDots")
        } else if card.isCreditCard {
            return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
        } else {
            return LocalizedStylableText(text: "", styles: nil)
        }
    }
    
    private func formattedSubtitle(card: Card) -> LocalizedStylableText? {
        guard let pan = card.getDetailUI().substring(card.getDetailUI().count - 4) else {
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
}

extension CardLimitManagementConfirmationPresenter: OperativeConfirmationPresenterProtocol {
    var infoTitle: LocalizedStylableText? {
        return nil
    }
    
    var toolTipMessage: LocalizedStylableText? {
        return nil
    }
    
    func onContinueButtonClicked() {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getCardLimitManagementValidationUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.container?.saveParameter(parameter: response.signatureWithToken)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                }
            }
        )
    }
}
