import CoreFoundationLib

final class SepaTransferSummaryPresenter: OperativeSummaryPresenter {
    override var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity.transferSummary(pageForMetrics: TrackerPagePrivate.InternationalTransferSummary().page)
    }
    
    override func onLoadedLocations() {
        evaluateLocations()
    }
    
    private func trackSeeOffer(location: PullOfferLocation, offer: Offer) {
        trackEvent(eventId: TrackerPagePrivate.Generic.Action.seeOffer.rawValue, parameters: [TrackerDimensions.location: location.stringTag, TrackerDimensions.offerId: offer.id ?? ""])
    }
    
    private func trackExecuteOffer(location: PullOfferLocation, offer: Offer?) {
        trackEvent(eventId: TrackerPagePrivate.Generic.Action.inOffer.rawValue, parameters: [TrackerDimensions.location: location.stringTag, TrackerDimensions.offerId: offer?.id ?? ""])
    }
    
    func finance() {
        let operativeData: OnePayTransferOperativeData = containerParameter()
        switch operativeData.easyPayFundableType {
        case .low:
            let offer = candidateLocations[.EASY_PAY_LOW_AMOUNT_SUMMARY]
            executeOffer(action: offer?.action, offerId: offer?.id, location: PullOfferLocation.EASY_PAY_LOW_AMOUNT_SUMMARY)
            trackExecuteOffer(location: .EASY_PAY_LOW_AMOUNT_SUMMARY, offer: offer)
            trackEvent(eventId: TrackerPagePrivate.NationalTransferSummary.Action.easyPay.rawValue, parameters: [:])
        case .high:
            let offer = candidateLocations[.EASY_PAY_HIGH_AMOUNT_SUMMARY]
            executeOffer(action: offer?.action, offerId: offer?.id, location: PullOfferLocation.EASY_PAY_HIGH_AMOUNT_SUMMARY)
            trackExecuteOffer(location: .EASY_PAY_HIGH_AMOUNT_SUMMARY, offer: offer)
            trackEvent(eventId: TrackerPagePrivate.NationalTransferSummary.Action.easyPay.rawValue, parameters: [:])
        case .notAllowed:
            trackEvent(eventId: TrackerPagePrivate.NationalTransferSummary.Action.easyPayError.rawValue, parameters: [:])
        }
    }
}

private extension SepaTransferSummaryPresenter {
    func evaluateLocations() {
        guard let (location, _) = self.candidateLocations.location(key: TransferPullOffers.paymentSummary) else {
            afterLocationsEvaluated()
            return
        }
        
        hasPaymentOneProduct { [weak self] result in
            self?.offerConditions[location] = result
            self?.afterLocationsEvaluated()
        }
    }
    
    private func hasPaymentOneProduct(_ completion: @escaping (Bool) -> Void) {
        let input = GetHasOneProductsUseCaseInput(product: \.paymentOneProducts)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getHasOneProductsUseCase(input: input),
            useCaseHandler: useCaseHandler,
            onSuccess: { result in
                completion(result.hasOneProduct)
            }, onError: { _ in
                completion(false)
        })
    }
    
    func afterLocationsEvaluated() {
        super.onLoadedLocations()
        let operativeData: OnePayTransferOperativeData = containerParameter()
        switch operativeData.easyPayFundableType {
        case .low:
            if let offer = candidateLocations[.EASY_PAY_LOW_AMOUNT_SUMMARY] {
                view.addAdditionalButton(title: localized(key: "transaction_buttom_installments"), action: finance)
                trackSeeOffer(location: .EASY_PAY_LOW_AMOUNT_SUMMARY, offer: offer)
            }
        case .high:
            if let offer = candidateLocations[.EASY_PAY_HIGH_AMOUNT_SUMMARY] {
                view.addAdditionalButton(title: localized(key: "transaction_buttom_installments"), action: finance)
                trackSeeOffer(location: .EASY_PAY_HIGH_AMOUNT_SUMMARY, offer: offer)
            }
        case .notAllowed:
            break
        }
    }
}
