import Operative
import CoreFoundationLib

final class DeleteFavouriteSummaryStep: OperativeStep {
    private let dependenciesResolver: DependenciesResolver
    weak var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperativeSummaryViewProtocol.self)
    }
    
    var presentationType: OperativeStepPresentationType {
        return .inNavigation(showsBack: false, showsCancel: false)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
