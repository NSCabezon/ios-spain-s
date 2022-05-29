import OpenCombine

public protocol PublicMenuRepository {
    func getPublicMenuConfiguration() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never>
}
