import OpenCombine
import CoreDomain
import UIKit

public protocol GetGlobalPositionBoxesUseCase {
    func fetchBoxesVisibles() -> AnyPublisher<[UserPrefBoxType], Never>
}

struct DefaultGlobalPositionBoxesUseCase: GetGlobalPositionBoxesUseCase {
    private let boxes: GetMyProductsUseCase
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        boxes = dependencies.resolve()
    }
}

extension DefaultGlobalPositionBoxesUseCase {
    func fetchBoxesVisibles() -> AnyPublisher<[UserPrefBoxType], Never> {
        var result: [UserPrefBoxType] = []
        return isVisibleAccountsEmpty
            .zip(isCardsMenuEmpty, isLoansMenuEmpty) { account, card, loan -> [UserPrefBoxType] in
                if !account {
                    result.append(.account)
                }
                if !card {
                    result.append(.card)
                }
                if !loan {
                    result.append(.loan)
                }
                return result
            }
            .zip(isFundsMenuEmpty, isDepositsMenuEmpty) { _, fund, deposit -> [UserPrefBoxType] in
                if !fund {
                    result.append(.fund)
                }
                if !deposit {
                    result.append(.deposit)
                }
                return result
            }
            .zip(isStocksMenuEmpty, isPensionsMenuEmpty) { _, stock, pension -> [UserPrefBoxType] in
                if !stock {
                    result.append(.stock)
                }
                if !pension {
                    result.append(.pension)
                }
                return result
            }
            .zip(isInsuranceSavingMenuEmpty, isInsuranceProtectionMenuEmpty) { _, saving, protection -> [UserPrefBoxType] in
                if !saving {
                    result.append(.insuranceSaving)
                }
                if !protection {
                    result.append(.insuranceProtection)
                }
                return result
            }
            .zip(isPortfolioManagedMenuEmpty, isPortfolioNotManagedMenuEmpty) { _, portfolio, notPortfolio -> [UserPrefBoxType] in
                if !portfolio {
                    result.append(.managedPortfolio)
                }
                if !notPortfolio {
                    result.append(.notManagedPortfolio)
                }
                return result
            }
            .map { $0 }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
}

private extension DefaultGlobalPositionBoxesUseCase {
    // MARK: - Helpers
    var isVisibleAccountsEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.account)
    }
    var isCardsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.card)
    }
    var isLoansMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.loan)
    }
    var isFundsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.fund)
    }
    var isDepositsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.deposit)
    }
    var isStocksMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.stock)
    }
    var isPensionsMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.pension)
    }
    var isInsuranceSavingMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.insuranceSaving)
    }
    var isInsuranceProtectionMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.insuranceProtection)
    }
    var isPortfolioManagedMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.managedPortfolio)
    }
    var isPortfolioNotManagedMenuEmpty: AnyPublisher<Bool, Never> {
        return isEmptyProduct(.notManagedPortfolio)
    }
    
    func isEmptyProduct(_ product: UserPrefBoxType) -> AnyPublisher<Bool, Never> {
        return boxes.fetchMyProducts()
            .map() { value -> Bool in
                let product = value[product]?.productsRepresentable.map { $0.value }
                return product?.filter { $0.isVisible == true }.isEmpty ?? true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}

