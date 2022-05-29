import CoreFoundationLib
import CoreDomain

struct ProductDetailProfileFactory {
    var product: GenericProductProtocol?
    var productDetail: GenericProductProtocol?
    var productHome: PrivateMenuProductHome
    var errorHandler: GenericPresenterErrorHandler
    var dependencies: PresentationComponent
    var delegate: ProductDetailProfileDelegate?
    let shareDelegate: ShowShareType?

    func makeDetailProfile() -> ProductDetailProfile? {
        switch productHome {
        case .funds:
            return FundDetailProfile(product: product,
                                     errorHandler: errorHandler,
                                     dependencies: dependencies,
                                     shareDelegate: shareDelegate)
            
        case .pensions:
            let pensionsDetailProfile = PensionDetailProfile(product: product,
                                        errorHandler: errorHandler,
                                        dependencies: dependencies,
                                        shareDelegate: shareDelegate)
            pensionsDetailProfile.delegate = delegate
            return pensionsDetailProfile
        case .deposits:
            let depositDetailProfile = DepositDetailProfile(product: product,
                                                            errorHandler: errorHandler,
                                                            dependencies: dependencies,
                                                            shareDelegate: shareDelegate)
            depositDetailProfile.delegate = delegate
            return depositDetailProfile
        case .impositionDetail:
            return ImpositionsDetailProfile(product: product,
                                            errorHandler: errorHandler,
                                            dependencies: dependencies,
                                            shareDelegate: shareDelegate)
            
        case .portfolioProductDetail:
            return PortfolioProductDetailProfile(product: product,
                                                 errorHandler: errorHandler,
                                                 dependencies: dependencies,
                                                 shareDelegate: shareDelegate)
        case .liquidationDetail:
            return LiquidationDetailProfile(product: product,
                                            errorHandler: errorHandler,
                                            dependencies: dependencies,
                                            shareDelegate: shareDelegate)
            
        default:
            return nil
        }
    }
}
