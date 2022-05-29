import CoreFoundationLib

public protocol OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity { get }
}

public extension OperativeOpinatorCapable where Self: Operative {
    
    func showOpinator() {
        self.container?.coordinator.handleOpinator(self.opinator)
    }
}
