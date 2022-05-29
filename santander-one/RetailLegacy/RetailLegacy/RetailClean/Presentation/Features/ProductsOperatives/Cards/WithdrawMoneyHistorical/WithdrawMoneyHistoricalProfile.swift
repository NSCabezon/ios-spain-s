import CoreFoundationLib
import CoreDomain

class WithdrawMoneyHistoricalProfile: BaseProductHomeProfile<Card, Any, GetDispensationsUseCaseInput, GetDispensationsUseCaseOkOutput, StringErrorOutput, Dispensation> {

    let container: OperativeContainerProtocol
    let cardDetail: CardDetail?
    let signatureWithToken: SignatureWithToken
    
    override var isHeaderCellHidden: Bool {
        return true
    }
    
    override var isMorePages: Bool {
        return false
    }
    
    override var currentPosition: Int? {
        get {
            return 0
        }
        //swiftlint:disable unused_setter_value
        set {
            
        }
        //swiftlint:enable unused_setter_value
    }
    
    override var transactionHeaderTitle: LocalizedStylableText? {
        return .empty
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return nil
    }

    // MARK: -

    init(container: OperativeContainerProtocol, selectedProduct: GenericProduct?, cardDetail: CardDetail?, signatureWithToken: SignatureWithToken, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        self.container = container
        self.cardDetail = cardDetail
        self.signatureWithToken = signatureWithToken
        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
    }
    
    override func convertToProductHeader(element: Card, position: Int) -> CarouselItem {
        return VoidCarouselItem()
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [Card] {
        guard let card = selectedProduct as? Card else {
            return []
        }
        return [card]
    }
    
    override func useCaseForTransactions<Input, Response, Error: StringErrorOutput>(pagination: PaginationDO?) -> UseCase<Input, Response, Error>? {
        let input = GetDispensationsUseCaseInput(container: container)
        return dependencies.useCaseProvider.getDispensationsUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    override func paginationFrom(response: GetDispensationsUseCaseOkOutput) -> PaginationDO? {
        return nil
    }
    
    override func transactionsFrom(response: GetDispensationsUseCaseOkOutput) -> [Dispensation]? {
        return response.dispensationsList.list
    }
    
    override func convertToDateProvider(from dispensation: Dispensation) -> DateProvider {
        return DispensationViewModel(product: dispensation, privateComponent: dependencies)
    }
    
    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        completionOptions?([])
    }
}

extension WithdrawMoneyHistoricalProfile: ProductProfile {
    
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_historyWhitdraw")
    }
        
    var loadingPlaceholder: Placeholder {
        return Placeholder("", 0.0)
    }
    
    var isFilterIconVisible: Bool {
        return false
    }
    
    var showNavigationInfo: Bool {
        return false
    }
    
    func transactionDidSelected(at index: Int) {
        if let card = currentProduct as? Card {
            delegate?.goToTransactionDetail(product: card, transactions: transactionList, selectedPosition: index, productHome: .cardDispensation)
        }
    }
}
