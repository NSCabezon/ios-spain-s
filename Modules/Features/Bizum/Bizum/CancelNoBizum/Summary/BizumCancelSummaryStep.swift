import Operative
import CoreFoundationLib

struct BizumCancelSummaryStep: OperativeStep {
    let dependenciesResolver: DependenciesResolver
    
    var presentationType: OperativeStepPresentationType {
        .inNavigation(showsBack: false, showsCancel: true)
    }
    
    var view: OperativeView? {
        self.dependenciesResolver.resolve(for: OperativeSummaryViewProtocol.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}
