import Foundation
import CoreFoundationLib
import OpenCombine
import Menu

final class SpainPublicMenuRepository: PublicMenuRepository {
    func getPublicMenuConfiguration() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return Just(SpainPublicMenuConfiguration().items).eraseToAnyPublisher()
    }
}
