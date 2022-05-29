import Foundation
import CoreFoundationLib

class PayLaterCardConfirmationPresenter: OperativeStepPresenter<PayLaterCardConfirmationViewController, VoidNavigator, PayLaterCardConfirmationPresenterProtocol> {
    private var payLaterCard: PayLaterCard?
    
    var card: Card? {        
        return payLaterCard?.originCard
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.PayLaterConfirmation().page
    }
    
    private func formattedTitle() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("pg_label_outstandingBalanceDots")
    }
    
    private func formattedSubtitle() -> LocalizedStylableText? {
        guard let card = card, let pan = card.getDetailUI().substring(card.getDetailUI().count - 4) else {
            return nil
        }
        let panDescription = "***" + pan
        return dependencies.stringLoader.getString("pg_label_creditCard", [StringPlaceholder(.value, panDescription)])
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        let operativeData: PayLaterCardOperativeData = containerParameter()
        payLaterCard = operativeData.payLaterCard
        
        let cardSection = TableModelViewSection()
        let cardHeader = TitledTableModelViewHeader()
        cardHeader.title = stringLoader.getString("confirmation_item_card")
        cardHeader.titleIdentifier = "payLaterConfirmation_cardTitle"
        cardSection.setHeader(modelViewHeader: cardHeader)
        let cardItem = CardConfirmationModelView(name: card?.getAliasUpperCase(), type: formattedSubtitle(), header: formattedTitle(), avaliable: card?.getAmountUI(), image: card?.buildImageRelativeUrl(true), dependencies: dependencies, identifiers: CardConfirmationModelViewIdentifiers(
            titleLabelIdentifier: AccessibilityCardPayLater.confirmHeaderTitle,
            subtitleLabelIdentifier: AccessibilityCardPayLater.confirmHeaderSubtitle,
            rightTitleLabelIdentifier: AccessibilityCardPayLater.confirmHeaderRightTitle,
            rightSubtitleLabelIdentifier: AccessibilityCardPayLater.confirmHeaderRightSubtitle,
            cardImageIdentifier: AccessibilityCardPayLater.confirmHeaderCardImage))
        cardSection.items = [cardItem]
        
        let payLaterSection = TableModelViewSection()
        let payLaterHeader = TitledTableModelViewHeader()
        payLaterHeader.title = stringLoader.getString("confirmation_label_payLater")
        payLaterHeader.titleIdentifier = AccessibilityCardPayLater.confirmTitleSection
        payLaterSection.setHeader(modelViewHeader: payLaterHeader)
        
        let amount: Amount? = payLaterCard?.amountToDefer
        let confirmationHeader = ConfirmationTableViewHeaderModel((amount ?? Amount.createWith(value: 0)).getFormattedAmountUI(), suffixIdentifier: AccessibilityCardPayLater.confirmAmount, dependencies)
        payLaterSection.items.append(confirmationHeader)
        
        guard let amountToPayLater = payLaterCard?.amountToPayLater else { return }
        
        let operatorItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_postponeAmount"),
                                                          amountToPayLater.getAbsFormattedAmountUI(),
                                                          false,
                                                          dependencies,
                                                          accessibilityIdentifier: AccessibilityCardPayLater.confirmOperatorInfo,
                                                          descriptionIdentifier: AccessibilityCardPayLater.confirmOperatorInfoDesc,
                                                          valueIdentifier: AccessibilityCardPayLater.confirmOperatorInfoValue)
        payLaterSection.items.append(operatorItem)
        
        let date = dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy)
        let dateItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_date"),
                                                      date ?? "",
                                                      true,
                                                      dependencies,
                                                      accessibilityIdentifier: AccessibilityCardPayLater.confirmDateInfo,
                                                      descriptionIdentifier: AccessibilityCardPayLater.confirmDateInfoDesc,
                                                      valueIdentifier: AccessibilityCardPayLater.confirmDateInfoValue)
        payLaterSection.items.append(dateItem)
        
        let infoLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("confirmation_text_signingAutomatic"), style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .center), insets: Insets(left: 14, right: 14, top: 5, bottom: 0), titleIdentifier: "payLaterConfirm_infoSectionFirst", privateComponent: dependencies)
        payLaterSection.items.append(infoLabelModel)
        
        let separatorViewCell = OperativeSeparatorModelView(insets: Insets(left: 20, right: 20, top: 9, bottom: 9), privateComponent: dependencies)
        payLaterSection.add(item: separatorViewCell)
        
        let info2LabelModel = OperativeLabelTableModelView(title: stringLoader.getString("confirmation_text_laidDownConditionsPay"), style: LabelStylist(textColor: .sanGreyMedium, font: .latoRegular(size: 14), textAlignment: .center), insets: Insets(left: 14, right: 14, top: 0, bottom: 14), titleIdentifier: "payLaterConfirm_infoSectionSecond", privateComponent: dependencies)
        payLaterSection.items.append(info2LabelModel)
        
        view.sections = [cardSection, payLaterSection]
    }
}

extension PayLaterCardConfirmationPresenter: PayLaterCardConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        guard let card = card, let amountToDefer = payLaterCard?.amountToDefer, let payLater = payLaterCard?.payLater else { return }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidatePayLaterCardUseCaseInput(card: card, amountToDefer: amountToDefer, payLater: payLater)
        let usecase = useCaseProvider.validatePayLaterCardUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
            }, onError: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(completion: {
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                })
        })
    }
}
