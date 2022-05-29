import Foundation
import CoreFoundationLib

protocol TipListDependenciesResolver {
    var external: TipListExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
