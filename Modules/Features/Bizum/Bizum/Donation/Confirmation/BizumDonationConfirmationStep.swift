import Operative
import CoreFoundationLib

final class BizumDonationConfirmationStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumDonationConfirmationViewProtocol.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
