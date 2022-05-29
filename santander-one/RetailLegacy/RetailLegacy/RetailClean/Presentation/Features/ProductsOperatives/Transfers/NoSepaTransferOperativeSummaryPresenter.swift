import CoreFoundationLib

final class NoSepaTransferOperativeSummaryPresenter: OperativeSummaryPresenter {
    override var locations: [PullOfferLocation] {
        PullOffersLocationsFactoryEntity.transferSummary(pageForMetrics: TrackerPagePrivate.NoSepaTransferSummary().page)
    }
    
    override func onLoadedLocations() {
        evaluateLocations()
    }
}

private extension NoSepaTransferOperativeSummaryPresenter {
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
    }
}
