
import Foundation
import OpenCombine

public protocol PublicMenuActionsRepository {
    func send()
    func reloadPublicMenu() -> AnyPublisher<Bool, Never>
}
