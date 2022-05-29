import CoreFoundationLib
import Operative

final class ConfirmationAmortizationStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        if let confirmationViewModifier = self.dependenciesResolver.resolve(forOptionalType: ConfirmationAmortizationStepViewModifierProtocol.self) {
            return confirmationViewModifier
        }
        return self.dependenciesResolver.resolve(for: ConfirmationAmortizationStepViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
