import CoreFoundationLib
import Foundation
import CoreDomain
import OpenCombine

struct DefaultSegmentedUserRepository: BaseRepository {
    
    typealias T = SegmentedUserDTO
    
    let datasource: NetDataSource<SegmentedUserDTO, CodableParser<SegmentedUserDTO>>
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "segmentosDefV2.json")
        let parser = CodableParser<SegmentedUserDTO>()
        datasource = FullDataSource<SegmentedUserDTO, CodableParser<SegmentedUserDTO>>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension DefaultSegmentedUserRepository: SegmentedUserRepository {
    
    private struct DefaultError: Error {}
    func getSegmentedUser() -> SegmentedUserDTO? {
        return get()
    }
    func getSegmentedUserSpb() -> [SegmentedUserTypeDTO]? {
        return get()?.spb
    }
    func getSegmentedUserGeneric() -> [SegmentedUserTypeDTO]? {
        return get()?.generic
    }
    
    func getCommercialSegment() -> AnyPublisher<CommercialSegmentRepresentable?, Never> {
        let matcher = SegmentedUserMatcher(isPB: false, repository: self)
        guard let commercialSegmentDto = matcher.retrieveUserSegment(bdpType: nil, comCode: nil)
        else { return Just(nil).eraseToAnyPublisher() }
        return Just(CommercialSegmentEntity(dto: commercialSegmentDto))
            .eraseToAnyPublisher()
    }
}
