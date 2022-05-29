import Foundation
import CoreFoundationLib
import CoreDomain

struct ProductProfileFactory {

    var selectedProduct: GenericProduct?
    var productHome: PrivateMenuProductHome
    var errorHandler: GenericPresenterErrorHandler
    var dependencies: PresentationComponent
    var profileDelegate: ProductHomeProfileDelegate
    let shareDelegate: ShowShareType?

    func makeProfile() -> ProductProfile? {
        switch productHome {

        case .funds:
            return FundProfile(selectedProduct: selectedProduct,
                    dependencies: dependencies,
                    errorHandler: errorHandler,
                    delegate: profileDelegate,
                    shareDelegate: shareDelegate)
        case .pensions:
            return PensionProfile(selectedProduct: selectedProduct,
                                  dependencies: dependencies,
                                  errorHandler: errorHandler,
                                  delegate: profileDelegate,
                                  shareDelegate: shareDelegate)
            
        case .deposits:
            return DepositProfile(selectedProduct: selectedProduct,
                                  dependencies: dependencies,
                                  errorHandler: errorHandler,
                                  delegate: profileDelegate,
                                  shareDelegate: shareDelegate)
        case .stocks, .managedRVPortfolios, .notManagedRVPortfolios, .productProfileVariableIncomeNotManaged, .productProfileVariableIncomeManaged:
            return StockProfile(appStoreNavigator: dependencies.navigatorProvider.appStoreNavigator,
                                selectedProduct: selectedProduct,
                                dependencies: dependencies,
                                errorHandler: errorHandler,
                                delegate: profileDelegate,
                                shareDelegate: shareDelegate)
        case .insuranceProtection:
            return InsuranceProtectionProfile(selectedProduct: selectedProduct,
                                       dependencies: dependencies,
                                       errorHandler: errorHandler,
                                       delegate: profileDelegate,
                                       shareDelegate: shareDelegate)
        case .insuranceSavings:
            return InsuranceSavingProfile(selectedProduct: selectedProduct,
                                       dependencies: dependencies,
                                       errorHandler: errorHandler,
                                       delegate: profileDelegate,
                                       shareDelegate: shareDelegate)
        case .managedPortfolios:
            return PortfolioProfile(isManaged: true,
                                    selectedProduct: selectedProduct,
                                    dependencies: dependencies,
                                    errorHandler: errorHandler,
                                    delegate: profileDelegate,
                                    shareDelegate: shareDelegate)
        case .notManagedPortfolios:
            return PortfolioProfile(isManaged: false,
                                    selectedProduct: selectedProduct,
                                    dependencies: dependencies,
                                    errorHandler: errorHandler,
                                    delegate: profileDelegate,
                                    shareDelegate: shareDelegate)
        case .orders:
            return OrdersProfile(selectedProduct: selectedProduct,
                                 dependencies: dependencies,
                                 errorHandler: errorHandler,
                                 delegate: profileDelegate,
                                 shareDelegate: shareDelegate)
        case .liquidation:
            return LiquidationProfile(selectedProduct: selectedProduct,
                                      dependencies: dependencies,
                                      errorHandler: errorHandler,
                                      delegate: profileDelegate,
                                      shareDelegate: shareDelegate)
        default:
            return nil
        }
    }
}
