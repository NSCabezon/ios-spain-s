import Foundation

public protocol BaseDataSource: DataSourcePublic {
    associatedtype T
    associatedtype P: Parser
    var dto: T? { get set }
    var parser: P { get set }
    var publicLanguage: PublicLanguage? { get set }
    var parameters: BaseDataSourceParameters { get }
    var assetsClient: AssetsClient { get }
}

extension BaseDataSource where P.Parseable == T {
    public func buildLocalizedPath(baseURL: String) -> String {
        let localPath = buildLocalizedLocalPath()
        let path = baseURL as NSString
        return path.appendingPathComponent(localPath)
    }
    
    public func buildLocalizedLocalPath() -> String {
        let language: PublicLanguage
        if let publicLanguage = publicLanguage {
            language = publicLanguage
        } else {
            language = .spanish
        }
        let path = parameters.relativeURL as NSString
        return path.appendingPathComponent(language.prefix + parameters.fileName)
    }
    
    public func load(baseUrl: String) {
        load(baseUrl: baseUrl, publicLanguage: .spanish)
    }
    
    public func loadFromAssets(baseURL: String) {
        let path = buildLocalizedPath(baseURL: baseURL)
        guard
            let response = assetsClient.get(path: path),
            let responseDTO = self.parser.serialize(response)
        else { return }
        self.dto = responseDTO
    }
}
