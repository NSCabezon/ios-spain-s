import Foundation
import OpenCombine
import CoreDomain

public class DefaultPublicMenuActionRepository: PublicMenuActionsRepository {
    
    private var subject = CurrentValueSubject<Bool, Never>(false)
    
    public init() {}
    
    public func send() {
        subject.send(true)
    }
    
    public func reloadPublicMenu() -> AnyPublisher<Bool, Never> {
        return subject.eraseToAnyPublisher()
    }
}
