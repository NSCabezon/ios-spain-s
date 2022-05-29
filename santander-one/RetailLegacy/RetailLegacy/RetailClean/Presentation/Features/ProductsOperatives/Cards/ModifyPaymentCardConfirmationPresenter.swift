import Foundation

class ModifyPaymentCardConfirmationPresenter: OperativeStepPresenter<ModifyPaymentCardConfirmationViewController, VoidNavigator, ModifyPaymentCardConfirmationPresenterProtocol> {
    private var cardModifyPaymentForm: CardModifyPaymentForm?
    
    // Card information
    var card: Card? {
        return cardModifyPaymentForm?.card
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
    
   override var screenId: String? {
        return TrackerPagePrivate.CreditCardChangePayMethodConfirmation().page
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("genericToolbar_title_confirmation")
        view.confirmButtonTitle = stringLoader.getString("generic_button_confirm")
        
        let operativeData: CardModifyPaymentFormOperativeData = containerParameter()
        cardModifyPaymentForm = operativeData.cardModifyPaymentForm
        
        let cardSection = TableModelViewSection()
        let cardHeader = TitledTableModelViewHeader()
        cardHeader.title = stringLoader.getString("confirmation_item_card")
        cardHeader.titleIdentifier = "changeWayToPayConfirmation_headerTitle"
        cardSection.setHeader(modelViewHeader: cardHeader)
        let cardItem = CardConfirmationModelView(name: card?.getAliasUpperCase(),
                                                 type: formattedSubtitle(),
                                                 header: formattedTitle(),
                                                 avaliable: card?.getAmountUI(),
                                                 image: card?.buildImageRelativeUrl(true),
                                                 dependencies: dependencies,
                                                 identifiers: CardConfirmationModelViewIdentifiers(titleLabelIdentifier: "changeWayToPayConfirmation_header_title", subtitleLabelIdentifier: "changeWayToPayConfirmation_header_subtitle", rightTitleLabelIdentifier: "changeWayToPayConfirmation_header_rightTitle", rightSubtitleLabelIdentifier: "changeWayToPayConfirmation_header_rightSubtitle", cardImageIdentifier: "changeWayToPayConfirmation_header_cardImage"))
        cardSection.items = [cardItem]
        
        let modifyPaymentSection = TableModelViewSection()
        let modifyPaymentHeader = TitledTableModelViewHeader()
        modifyPaymentHeader.title = stringLoader.getString("confirmation_label_payMethod")
        modifyPaymentHeader.titleIdentifier = "changeWayToPayConfirmation_titleSection"
        modifyPaymentSection.setHeader(modelViewHeader: modifyPaymentHeader)
        
        // Old payment method
        if let paymentMethodStatus = cardModifyPaymentForm?.currentChangePayment?.paymentMethodStatus {
            let previousDescription = PaymentMethodDescription(dependencies: dependencies,
                                                               paymentMethodStatus: paymentMethodStatus,
                                                               title: Int(cardModifyPaymentForm?.oldAmount?.value?.doubleValue ?? 0.0),
                                                               subtitle: Int(cardModifyPaymentForm?.oldPaymentMethod?.minAmortAmount?.value?.doubleValue ?? 0.0))
            let amountOldPaymentItem = SimpleConfirmationTableViewHeaderModel(stringLoader.getString("confirmation_item_previousPay"),
                                                                              previousDescription.paymentMethodDescription() ?? "", inputIdentifier: "changeWayToPayConfirmation_oldMethod",
                                                                              false,
                                                                              dependencies)
            modifyPaymentSection.items.append(amountOldPaymentItem)
        }
        
        // New payment method
        if let paymentMethodStatus = cardModifyPaymentForm?.newPaymentMethodStatus {
            let newDescription = PaymentMethodDescription(dependencies: dependencies,
                                                          paymentMethodStatus: paymentMethodStatus,
                                                          title: Int(cardModifyPaymentForm?.amount?.value?.doubleValue ?? 0.0),
                                                          subtitle: Int(cardModifyPaymentForm?.newPaymentMethod?.minAmortAmount?.value?.doubleValue ?? 0.0))
            let amountNewPaymentItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_newPay"),
                                                                      newDescription.paymentMethodDescription() ?? "",
                                                                      false,
                                                                      dependencies,
                                                                      descriptionIdentifier: "changeWayToPayConfirmation_newMethod_title",
                                                                      valueIdentifier: "changeWayToPayConfirmation_newMethod_value")
            modifyPaymentSection.items.append(amountNewPaymentItem)
        }
        
        let date = dependencies.timeManager.toString(date: Date(), outputFormat: .d_MMM_yyyy)
        let dateItem = ConfirmationTableViewItemModel(stringLoader.getString("confirmation_item_date"),
                                                      date ?? "",
                                                      true,
                                                      dependencies,
                                                      descriptionIdentifier: "changeWayToPayConfirmation_date_title",
                                                      valueIdentifier: "changeWayToPayConfirmation_date_value")
        modifyPaymentSection.items.append(dateItem)
        
        let infoLabelModel = OperativeLabelTableModelView(title: stringLoader.getString("confirmation_label_operativeNotSing"),
                                                          style: LabelStylist(textColor: .sanGreyMedium,
                                                                              font: .latoRegular(size: 14),
                                                                              textAlignment: .center),
                                                          insets: Insets(left: 14, right: 14, top: 5, bottom: 0),
                                                          titleIdentifier: "changeWayToPayConfirmation_footerSection",
                                                          privateComponent: dependencies)
        modifyPaymentSection.items.append(infoLabelModel)
        
        view.sections = [cardSection, modifyPaymentSection]
    }
}

extension ModifyPaymentCardConfirmationPresenter: ModifyPaymentCardConfirmationPresenterProtocol {
    func confirmButtonTouched() {
        guard let operativeData: CardModifyPaymentFormOperativeData = container?.provideParameter(),
            let cardModifyPaymentForm = operativeData.cardModifyPaymentForm,
            let changePayment = cardModifyPaymentForm.currentChangePayment,
            let selectedPaymentMethod = cardModifyPaymentForm.newPaymentMethod,
            let amount = cardModifyPaymentForm.amount else {
            return
        }
        
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let caseInput = ConfirmCardModifyPaymentFormUseCaseInput(card: cardModifyPaymentForm.card,
                                                                 changePayment: changePayment,
                                                                 selectedPaymentMethod: selectedPaymentMethod,
                                                                 amount: amount)
        UseCaseWrapper(with: useCaseProvider.confirmCardModifyPaymentFormUseCase(input: caseInput), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.hideLoading(completion: {
                strongSelf.container?.stepFinished(presenter: strongSelf)
            })
            }, onError: { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(completion: {
                    strongSelf.showError(keyDesc: error?.getErrorDesc())
                    var parameters: [String: String] = [:]
                    if let errorDesc = error?.getErrorDesc() {
                        var error = errorDesc
                        if let wsError = strongSelf.stringLoader.getWsErrorIfPresent(error) {
                            error = wsError.text
                        }
                        parameters[TrackerDimensions.descError] = error
                    }
                    self?.dependencies.trackerManager.trackEvent(screenId: TrackerPagePrivate.CreditCardChangePayMethodConfirmation().page,
                                                                 eventId: TrackerPagePrivate.CreditCardChangePayMethodConfirmation.Action.error.rawValue,
                                                                 extraParameters: parameters)
                })
        })
    }
}
