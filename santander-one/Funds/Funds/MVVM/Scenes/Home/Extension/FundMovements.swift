//
//  FundMovements.swift
//  Funds
//

import CoreFoundationLib
import CoreDomain

struct FundMovements {
    let fund: FundRepresentable
    let movements: [FundMovementRepresentable]
    let stringLoader: StringLoader
    let movementsModifier: FundsHomeMovementsModifier?

    init(fund: FundRepresentable, movements: [FundMovementRepresentable], dependencies: FundsHomeDependenciesResolver) {
        self.fund = fund
        self.movements = movements
        self.stringLoader = dependencies.external.resolve()
        self.movementsModifier = dependencies.external.common.resolve()
    }

    init(fund: FundRepresentable, movements: [FundMovementRepresentable], dependencies: FundTransactionsDependenciesResolver) {
        self.fund = fund
        self.movements = movements
        self.stringLoader = dependencies.external.resolve()
        self.movementsModifier = dependencies.external.common.resolve()
    }

    var hasMoreThanThreeMovements: Bool {
        self.movements.count > 3
    }

    var lastThreeMovements: [FundMovementRepresentable] {
        guard movements.isNotEmpty else { return [] }
        let maxLastMovements = movements.count > 3 ? 3 : movements.count
        return Array(movements[0..<maxLastMovements])
    }

    var currentLocale: Locale {
        let identifier = stringLoader.getCurrentLanguage().languageType.rawValue
        return Locale(identifier: identifier)
    }

    func getUnits(for movement: FundMovementRepresentable) -> String {
        return movementsModifier?.getUnits(for: movement) ?? movement.unitsRepresentable ?? "0"
    }
}
