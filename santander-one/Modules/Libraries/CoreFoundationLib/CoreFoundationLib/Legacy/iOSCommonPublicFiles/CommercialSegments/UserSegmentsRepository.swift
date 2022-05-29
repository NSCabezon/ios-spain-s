

public class UserSegmentsRepository: BaseRepository {
    public typealias T = SegmentsListDTO
    public let datasource: FullDataSource<SegmentsListDTO, UserSegmentsParser>
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "apps/SAN/", fileName: "segmentosDef.xml")
        let parser = UserSegmentsParser()
        datasource = FullDataSource<SegmentsListDTO, UserSegmentsParser>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}
