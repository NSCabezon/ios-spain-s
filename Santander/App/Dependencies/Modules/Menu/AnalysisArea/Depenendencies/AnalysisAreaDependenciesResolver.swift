//  Created by Jose Javier Montes Romero on 28/1/22.
//

import Foundation
import Menu
import CoreDomain
import CoreFoundationLib
import UI
import RetailLegacy

extension ModuleDependencies: AnalysisAreaExternalDependenciesResolver {
    func resolve() -> UserSessionFinancialHealthRepository {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> FinancialHealthRepository {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func offersCoordinator() -> BindableCoordinator {
        return resolveOfferCoordinator()
    }
    
    func otpCoordinator() -> BindableCoordinator {
        resolveOTPCoordinator()
    }
}
