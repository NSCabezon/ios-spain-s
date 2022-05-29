import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public struct FractionedPaymentsDetailMovementsViewModel {
    public let dayMovements: [FractionablePurchaseViewModel]
    public let date: Date
    private let dependenciesResolver: DependenciesResolver
    private let timeManager: TimeManager
    
    public init(_ movements: [FractionablePurchaseViewModel], date: Date, dependenciesResolver: DependenciesResolver) {
        self.dayMovements = movements
        self.date = date
        self.dependenciesResolver = dependenciesResolver
        self.timeManager = dependenciesResolver.resolve(for: TimeManager.self)
    }
    
    public func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText {
        let decorator = DateDecorator(self.date)
        return decorator.setDateFormatter(filtered)
    }
}
