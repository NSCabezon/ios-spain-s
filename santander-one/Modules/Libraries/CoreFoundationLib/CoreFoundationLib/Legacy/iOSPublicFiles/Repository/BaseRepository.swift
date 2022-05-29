
public protocol BaseRepository: Repository {
    associatedtype S: DataSourcePublic where S.T == T
    var datasource: S { get }
}

extension BaseRepository {
    public func get() -> T? {
        return datasource.getType()
    }
    
    public func load(withBaseUrl url: String) {
        return datasource.load(baseUrl: url)
    }
    
    public func load(baseUrl: String, publicLanguage: PublicLanguage) {
        return datasource.load(baseUrl: baseUrl, publicLanguage: publicLanguage)
    }
    
    public func remove() {
        datasource.remove()
    }
}
