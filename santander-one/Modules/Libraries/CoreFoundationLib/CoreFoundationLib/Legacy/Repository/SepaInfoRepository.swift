import Foundation
import CoreDomain
import OpenCombine

public struct SepaInfoRepository: BaseRepository {
    
    public typealias T = SepaInfoListDTO
    
    public let datasource: FullDataSource<SepaInfoListDTO, CodableParser<SepaInfoListDTO>>
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "sepa_infoV2.json")
        let parser = CodableParser<SepaInfoListDTO>()
        datasource = FullDataSource<SepaInfoListDTO, CodableParser<SepaInfoListDTO>>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension SepaInfoRepository: SepaInfoRepositoryProtocol {
    
    public func getSepaList() -> SepaInfoListDTO? {
        return get()
    }
}

extension SepaInfoRepository: ReactiveSepaInfoRepository {
     public func fetchSepaInfoPublisher() -> AnyPublisher<SepaInfoListRepresentable?, Error> {
         return Future { promise in
             guard let sepaInfoList = self.get() else { return promise(.success(nil)) }
             promise(.success(sepaInfoList))
         }.eraseToAnyPublisher()
     }
 }
