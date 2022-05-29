import CoreDomain
import OpenCombine

public protocol SegmentedUserRepository {
    func getSegmentedUser() -> SegmentedUserDTO?
    func getSegmentedUserSpb() -> [SegmentedUserTypeDTO]?
    func getSegmentedUserGeneric() -> [SegmentedUserTypeDTO]?
    func getCommercialSegment() -> AnyPublisher<CommercialSegmentRepresentable?, Never>
    func remove()
    func load(withBaseUrl url: String)
    func load(baseUrl: String, publicLanguage: PublicLanguage)
}
