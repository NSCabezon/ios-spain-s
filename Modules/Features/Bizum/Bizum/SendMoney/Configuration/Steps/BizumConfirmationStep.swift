import Operative
import CoreFoundationLib

final class BizumConfirmationStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumConfirmationViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
