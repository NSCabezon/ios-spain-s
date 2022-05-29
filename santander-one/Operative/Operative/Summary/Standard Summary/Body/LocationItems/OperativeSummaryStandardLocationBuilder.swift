import CoreFoundationLib

public final class OperativeSummaryStandardLocationBuilder {
    private let offers: [PullOfferLocation: OfferEntity]
    private var items: [OperativeSummaryStandardLocationViewModel] = []
    private var offerConditions: [PullOfferLocation: Bool]

    public init(offers: [PullOfferLocation: OfferEntity], offerConditions: [PullOfferLocation: Bool]) {
        self.offers = offers
        self.offerConditions = offerConditions
    }
    
    public func addPaymentLocation(forceLabelsHeight: Bool = false, executeOfferAction: @escaping (OfferEntity) -> Void) {
        guard
            offers.contains(location: TransferPullOffers.paymentSummary),
            let (location, offer) = offers.location(key: TransferPullOffers.paymentSummary),
            offerConditions[location] == true
            else { return }
        let item = OperativeSummaryStandardLocationViewModel(locationType: .payment,
                                                             viewModel: OperativeSummaryPaymentLocationViewModel(
                                                                forceLabelsHeight: forceLabelsHeight,
                                                                action: {
                                                                    executeOfferAction(offer)
                                                             }))
        self.items.append(item)
    }
    
    public func build() -> [OperativeSummaryStandardLocationViewModel] {
        return self.items
    }
}
