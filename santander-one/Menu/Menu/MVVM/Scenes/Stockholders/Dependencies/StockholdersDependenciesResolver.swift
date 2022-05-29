import Foundation
import CoreFoundationLib

protocol StockholdersDependenciesResolver {
    var external: StockholdersExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
