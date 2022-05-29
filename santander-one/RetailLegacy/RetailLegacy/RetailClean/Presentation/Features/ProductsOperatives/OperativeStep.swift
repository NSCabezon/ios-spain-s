enum StepPresentation {
    case inNavigation
    case modal
}

protocol OperativeStep {
    var presentationType: StepPresentation { get }
    var showsBack: Bool { get set }
    var showsCancel: Bool { get set }
    var number: Int { get set }
    var presenter: OperativeStepPresenterProtocol { get }
    
    init(presenterProvider: PresenterProvider, number: Int)
}

struct OperativeStepFactory {
    var presenterProvider: PresenterProvider
    
    func createStep<S: OperativeStep>() -> S {
        return S(presenterProvider: presenterProvider, number: -1)
    }
}
