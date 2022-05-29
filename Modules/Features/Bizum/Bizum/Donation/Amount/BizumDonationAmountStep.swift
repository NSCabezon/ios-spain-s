import Operative
import CoreFoundationLib

final class BizumDonationAmountStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumDonationAmountViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
