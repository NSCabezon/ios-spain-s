import Foundation
import CoreFoundationLib
import UIKit
import CoreDomain

class DepositProfile: BaseProductHomeProfile<Deposit, Void, GetImpositionsUseCaseInput, GetImpositionsUseCaseOkOutput, GetImpositionsUseCaseErrorOutput, Imposition>, ProductProfile {
    
    var menuOptionSelected: PrivateMenuOptions? {
        return .myProducts
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().depositsHome
    }
    
    var loadingPlaceholder: Placeholder {
        return Placeholder("productPlaceholderFakeMov", 14)
    }
    
    func product(at position: Int) -> GenericProduct {
        return productList[position]
    }
    
    var productTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("toolbar_title_deposits")
    }
        
    var isFilterIconVisible: Bool {
        return false
    }

    var showNavigationInfo: Bool {
        return false
    }

    // MARK: - TrackerScreenProtocol

    var screenId: String? {
        return TrackerPagePrivate.Deposit().page
    }

    // MARK: -
    private var presenterOffers: [PullOfferLocation: Offer] = [:]
    private lazy var options = [ProductOption]()
    
    override init(selectedProduct: GenericProduct?, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, delegate: ProductHomeProfileDelegate, shareDelegate: ShowShareType?) {
        super.init(selectedProduct: selectedProduct, dependencies: dependencies, errorHandler: errorHandler, delegate: delegate, shareDelegate: shareDelegate)
        getLocations()
    }

    override func convertToProductHeader(element: Deposit, position: Int) -> CarouselItem {
        let data = ProductHeader(title: element.getAlias() ?? "",
                                 subtitle: element.getDetailUI() ?? "",
                                 amount: element.getAmount(),
                                 pendingText: nil,
                                 isPending: false,
                                 isCopyButtonAvailable: true,
                                 copyTag: 1,
                                 isBigSeparator: needsExtraBottomSpace,
                                 shareDelegate: self)
        return CarouselGenericCell(data: data)
    }
    
    private func getLocations() {
        getCandidateOffers { [weak self] candidates in
            self?.presenterOffers = candidates
        }
    }
    
    override func extractProductList(globalPosition: GlobalPositionWrapper) -> [Deposit] {
        return globalPosition.deposits.get(ordered: true, visibles: true)
    }

    override func useCaseForTransactions<Input, Response, Error>(pagination: PaginationDO?) -> UseCase<Input, Response, Error>? where Error: StringErrorOutput {
        guard let currentPosition = currentPosition else {
            return nil
        }
        let deposit = productList[currentPosition]
        let input = GetImpositionsUseCaseInput(deposit: deposit, pagination: pagination)
        return dependencies.useCaseProvider.getImpositionsUseCase(input: input) as? UseCase<Input, Response, Error>
    }
    
    override func paginationFrom(response: GetImpositionsUseCaseOkOutput) -> PaginationDO? {
        return response.impositionsList.pagination
    }
    
    override func transactionsFrom(response: GetImpositionsUseCaseOkOutput) -> [Imposition]? {
        return response.impositionsList.impositions
    }
    
    override func convertToDateProvider(from imposition: Imposition) -> DateProvider {
        return ImpositionModelView(imposition, false, dependencies)
    }
    
    // MARK: - MenuOptions

    override func menuOptions(withProductConfig productConfig: ProductConfig) {
        if !options.isEmpty { options.removeAll() }
        options.append(DepositOptionsHandler.buildDetail(dependencies))
        
        if presenterOffers[.CONTRATAR_DEPOSITOS] != nil {
            options.append(DepositOptionsHandler.buildPurchaseDeposit(dependencies))
        }
        completionOptions?(options)
    }
    
    func optionDidSelected(at index: Int) {
        if let deposit = ProductsOptions.DepositOptions(rawValue: index) {
            switch deposit {
            case .detail:
                goToDetail()
            case .purchaseDeposit:
                goToPurchaseDeposit()
            }
            
        }
    }
    
    func goToDetail() {
        if let position = currentPosition {
            let product = productList[position]
            delegate?.goToDetail(product: product, productDetail: nil, productHome: .deposits)
        }
    }
    
    func goToPurchaseDeposit() {
        guard let offer = presenterOffers[.CONTRATAR_DEPOSITOS], let action = offer.action else {
            return
        }
        delegate?.executePullOfferAction(action: action, offerId: offer.id, location: .CONTRATAR_DEPOSITOS)
    }
    
    func transactionDidSelected(at index: Int) {
        guard let current = currentPosition else {
            return
        }
        transactionList.forEach { $0.deposit = productList[current] }
        delegate?.goToTransactionDetail(product: transactionList[index], transactions: transactionList, selectedPosition: index, productHome: .impositionsHome)
    }
    
    func showInfo() {
    }
    
    override func infoToShareWithCode(_ code: Int?) -> String? {
        let position = currentPosition ?? 0
        let product = productList[position]
        guard let info = product.getDetailUI() else {
            return nil
        }

        return info
    }
    
    override var transactionHeaderTitle: LocalizedStylableText? {
        return dependencies.stringLoader.getString("deposits_label_impositions").uppercased()
    }
    
    override func shareInfoWithCode(_ code: Int?) {
        if let screenId = self.screenId {
            delegate?.track(event: TrackerPagePrivate.Deposit.Action.copy.rawValue, screen: screenId, parameters: [:])
        }
        
        super.shareInfoWithCode(code)
    }
    
}

extension DepositProfile: LocationsResolver {
    var useCaseProvider: UseCaseProvider {
        return dependencies.useCaseProvider
    }
    
    var useCaseHandler: UseCaseHandler {
        return dependencies.useCaseHandler
    }
    
    var genericErrorHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
}
