import CoreDomain

public protocol GlobalPositionWithUserPrefMergeable {
    func merge(globalPosition: GlobalPositionDataRepresentable, userPref: UserPrefDTOEntity) -> GlobalPositionAndUserPrefMergedRepresentable
}

extension GlobalPositionWithUserPrefMergeable {
    public func merge(globalPosition: GlobalPositionDataRepresentable, userPref: UserPrefDTOEntity) -> GlobalPositionAndUserPrefMergedRepresentable {
        return DefaultGlobalPositionAndUserPrefMerged(
            loans: update(
                products: globalPosition.loanRepresentables,
                userPref: userPref
            ),
            accounts: update(
                products: globalPosition.accountRepresentables,
                userPref: userPref
            ),
            stockAccounts: update(
                products: globalPosition.stockAccountRepresentables,
                userPref: userPref
            ),
            cards: update(
                products: globalPosition.cardRepresentables,
                userPref: userPref
            ),
                deposits: update(
                    products: globalPosition.depositRepresentables,
                    userPref: userPref
                ),
            funds: update(
                products: globalPosition.fundRepresentables,
                userPref: userPref
            ),
            managedPortfolios: update(
                products: globalPosition.managedPortfoliosRepresentables,
                userPref: userPref,
                forcedBoxType: .managedPortfolio
            ),
            notManagedPortfolios: update(
                products: globalPosition.notManagedPortfoliosRepresentables,
                userPref: userPref,
                forcedBoxType: .notManagedPortfolio
            ),
            managedPortfolioVariableIncome: update(
                products: globalPosition.managedPortfolioVariableIncomeRepresentables,
                userPref: userPref,
                forcedBoxType: .managedPortfolioVariableIncome)
            ,
            notManagedPortfolioVariableIncome: update(
                products: globalPosition.notManagedPortfolioVariableIncomeRepresentables,
                userPref: userPref
            ),
            pensions: update(
                products: globalPosition.pensionRepresentables,
                userPref: userPref
            ),
            savingsInsurances: update(
                products: globalPosition.savingsInsuranceRepresentables,
                userPref: userPref,
                forcedBoxType: .insuranceSaving
            ),
            protectionInsurances: update(
                products: globalPosition.protectionInsuranceRepresentables,
                userPref: userPref,
                forcedBoxType: .insuranceProtection
            ),
            savingsProducts: update(
                products: globalPosition.savingProductRepresentables,
                userPref: userPref
            )
        )
    }
    
    private func update<Product>(
        products: [Product],
        userPref: UserPrefDTOEntity,
        forcedBoxType: UserPrefBoxType? = nil
    ) -> [GlobalPositionMergedProduct<Product>] {
        let boxes = userPref.pgUserPrefDTO.boxes
        guard let boxType = (forcedBoxType ?? (products.first as? GlobalPositionProductIdentifiable)?.boxType),
              let boxSelected = boxes[boxType]
        else { return products.map({ GlobalPositionMergedProduct(product: $0, isVisible: true) }) }
        var sortedProducts: [(Product, Int, Bool)] = []
        var missingProducts: [Product] = []
        for product in products {
            guard let productIdentifiable = product as? GlobalPositionProductIdentifiable else { continue }
            if let info = boxSelected.products[productIdentifiable.appIdentifier] {
                sortedProducts.append((product, info.order, info.isVisible))
            } else {
                missingProducts.append(product)
            }
        }
        sortedProducts = sortedProducts.sorted { $0.1 < $1.1 }
        var finalProducts: [GlobalPositionMergedProduct<Product>] = []
        finalProducts.append(contentsOf: sortedProducts.map({ GlobalPositionMergedProduct(product: $0.0, isVisible: $0.2) }))
        finalProducts.append(contentsOf: missingProducts.map({ GlobalPositionMergedProduct(product: $0, isVisible: true) }))
        return finalProducts
    }
}
