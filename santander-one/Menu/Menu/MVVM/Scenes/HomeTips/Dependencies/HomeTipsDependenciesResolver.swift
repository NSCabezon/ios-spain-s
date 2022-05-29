import Foundation
import CoreFoundationLib

protocol HomeTipsDependenciesResolver {
    var external: HomeTipsExternalDependenciesResolver { get }
    func resolve() -> DataBinding
}
