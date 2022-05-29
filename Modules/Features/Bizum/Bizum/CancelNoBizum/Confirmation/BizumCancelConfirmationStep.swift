import Foundation
import Operative
import CoreFoundationLib

final class BizumCancelConfirmationStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: true, showsCancel: true)
    }
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: BizumCancelConfirmationViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
