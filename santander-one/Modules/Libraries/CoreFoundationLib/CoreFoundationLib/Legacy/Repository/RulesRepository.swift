import CoreDomain
import OpenCombine

public struct RulesRepository: BaseRepository {
    public typealias T = [RuleDTO]
    public let datasource: FullDataSource<[RuleDTO], RulesParser>
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "rulesV4.xml")
        let parser = RulesParser()
        datasource = FullDataSource<[RuleDTO], RulesParser>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension RulesRepository: ReactiveRulesRepository {
    public func fetchRulesPublisher() -> AnyPublisher<[RuleRepresentable], Never> {
        return Future { promise in
            guard let rules = self.get() else { return promise(.success([])) }
            promise(.success(rules))
        }.eraseToAnyPublisher()
    }
}
