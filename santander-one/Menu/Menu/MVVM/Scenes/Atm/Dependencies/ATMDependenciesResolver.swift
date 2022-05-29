import Foundation
import CoreFoundationLib

protocol ATMDependenciesResolver {
    var external: ATMExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
