import OpenCombine

public protocol HomeTipsRepository {
    func getHomeTipsCount() -> AnyPublisher<Int, Never>
}
