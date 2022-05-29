import CoreFoundationLib
import UI

public protocol Operative: AnyObject {
    var dependencies: DependenciesResolver & DependenciesInjector { get }
    var container: OperativeContainerProtocol? { get set }
    var steps: [OperativeStep] { get set }
    var progressBarType: ProgressBarType { get }
}

public extension Operative {
    var progressBarType: ProgressBarType {
        return .stepped
    }
}
