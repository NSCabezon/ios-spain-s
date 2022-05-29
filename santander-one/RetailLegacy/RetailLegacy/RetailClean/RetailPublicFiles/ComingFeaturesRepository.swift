import CoreFoundationLib
import Foundation

struct ComingFeaturesRepository: BaseRepository {
    
    typealias T = ComingFeatureListDTO

    let datasource: NetDataSource<ComingFeatureListDTO, CodableParser<ComingFeatureListDTO>>
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "coming_features.json")
        let parser = CodableParser<ComingFeatureListDTO>()
        self.datasource = NetDataSource<ComingFeatureListDTO, CodableParser<ComingFeatureListDTO>>(parser: parser, parameters: parameters, assetsClient: assetsClient, netClient: netClient)
    }
}

extension ComingFeaturesRepository: ComingFeaturesRepositoryProtocol {
    func getFeatures() -> ComingFeatureListDTO? {
        return self.get()
    }
    
    func load(baseUrl: String, publicLanguage: PublicLanguage) {
        datasource.load(baseUrl: baseUrl, publicLanguage: publicLanguage)
    }
}
