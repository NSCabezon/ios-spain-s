import Operative
import CoreFoundationLib

final class BizumAmountStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }

    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumSendMoneyViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
