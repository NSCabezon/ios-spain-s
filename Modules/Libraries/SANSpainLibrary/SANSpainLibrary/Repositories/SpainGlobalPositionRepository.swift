import OpenCombine
import CoreDomain

public protocol SpainGlobalPositionRepository {
    func loadGlobalPositionV2(onlyVisibleProducts: Bool, isPB: Bool) -> AnyPublisher<GlobalPositionDataRepresentable, Error>
}
