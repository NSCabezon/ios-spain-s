import CoreDomain
import OpenCombine

public struct OffersRepository: BaseRepository {
    public typealias T = [OfferDTO]
    public let datasource: FullDataSource<[OfferDTO], OfferParser>
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient, parameters: BaseDataSourceParameters) {
        let parser = OfferParser()
        datasource = FullDataSource<[OfferDTO], OfferParser>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension OffersRepository: ReactiveOffersRepository {
    public func fetchOffersPublisher() -> AnyPublisher<[OfferRepresentable], Never> {
        return Future { promise in
            guard let offers = self.get() else { return promise(.success([])) }
            promise(.success(offers))
        }.eraseToAnyPublisher()
    }
}
