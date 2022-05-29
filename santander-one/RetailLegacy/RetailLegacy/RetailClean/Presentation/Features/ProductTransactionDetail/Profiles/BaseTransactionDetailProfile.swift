import CoreFoundationLib

protocol GenericTransactionProtocol {}
protocol GenericTransactionDelegate: class {
    func reloadAlias()
}

extension AccountTransaction: GenericTransactionProtocol {}
extension FundTransaction: GenericTransactionProtocol {}
extension PensionTransaction: GenericTransactionProtocol {}
extension CardTransaction: GenericTransactionProtocol {}
extension Imposition: GenericTransactionProtocol {}
extension Stock: GenericTransactionProtocol {}
extension Dispensation: GenericTransactionProtocol {}
extension BillAndAccount: GenericTransactionProtocol {}

extension AccountTransactionDetail: GenericTransactionProtocol {}
extension FundTransactionDetail: GenericTransactionProtocol {}
extension PortfolioProductTransactionDetail: GenericTransactionProtocol {}
extension CardTransactionDetail: GenericTransactionProtocol {}

class BaseTransactionDetailProfile<Input, Response, Error: StringErrorOutput> {
    
    weak var optionsDelegate: ProductOptionsDelegate?
    var product: GenericProductProtocol?
    let transaction: GenericTransactionProtocol
    var dependencies: PresentationComponent
    let errorHandler: GenericPresenterErrorHandler
    weak var transactionDetailManager: ProductLauncherOptionsPresentationDelegate?
    weak var delegate: (GenericTransactionDelegate & PullOfferActionsPresenter)?
    
    var completionActions: ((_ options: [TransactionDetailActionType]) -> Void)?
    
    var productConfig: ProductConfig? {
        didSet {
            guard let config = productConfig else { return }
            actions(withProductConfig: config)
        }
    }
    
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().transactionDetail
    }
    
    var productDetail: GenericProductProtocol?
    
    var shareableInfo = [TransactionLine]()
    
    var sideTitleText: LocalizedStylableText? {
        return nil
    }
    
    var sideDescriptionText: LocalizedStylableText? {
        return nil
    }
    
    var emmaScreenToken: String? {
        return nil
    }
    
    func actionTitle(completion: @escaping (LocalizedStylableText?) -> Void) {
        completion(nil)
    }
    
    func actionButton() {
    }
    
    init(product: GenericProductProtocol? = nil, transaction: GenericTransactionProtocol, dependencies: PresentationComponent, errorHandler: GenericPresenterErrorHandler, transactionDetailManager: ProductLauncherOptionsPresentationDelegate) {
        self.product = product
        self.transaction = transaction
        self.dependencies = dependencies
        self.errorHandler = errorHandler
        self.transactionDetailManager = transactionDetailManager
        requestActions()
    }
    
    func getLocation() -> PullOfferLocation? {
        return nil
    }
    
    func requestTransactionDetail(completion: @escaping ([TransactionLine]?) -> Void) {
                
        guard let uc: UseCase<Input, Response, Error> = useCaseForTransactionDetail() else {
            completion(nil)
            return
        }
        
        UseCaseWrapper(with: uc, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) -> Void in
            
            guard let strongSelf = self else { return }
            if let transactionDetail = strongSelf.transactionDetailFrom(response: result) {
                strongSelf.loadProductConfig {
                    completion(strongSelf.getInfoFromTransactionDetail(transactionDetail: transactionDetail))
                }
            }
            
        }, onError: {(_) -> Void in
            completion(nil)
        })
    }
        
    private func loadProductConfig(_ completion: @escaping () -> Void) {
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getProductConfigUseCase(),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] response in
                self?.productConfig = response.productConfig
                completion()
            },
            onError: { _ in
                completion()
            }
        )
    }
    
    func candidatesLocations(_ locations: [PullOfferLocation: Offer]) {}
    
    func actions(withProductConfig productConfig: ProductConfig) {
        fatalError()
    }
    
    func useCaseForTransactionDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        fatalError()
    }
    
    func transactionDetailFrom(response: Response) -> GenericTransactionProtocol? {
        fatalError()
    }
    
    func getInfoFromTransactionDetail(transactionDetail: GenericTransactionProtocol) -> [TransactionLine]? {
        fatalError()
    }
    
    func useCaseForProductDetail<Input, Response, Error: StringErrorOutput>() -> UseCase<Input, Response, Error>? {
        fatalError()
    }
    
    func requestActions() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getProductConfigUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (productConfigResponse) in
            guard let productConfig = productConfigResponse.productConfig else { return }
            self?.productConfig = productConfig
        })
    }
}
