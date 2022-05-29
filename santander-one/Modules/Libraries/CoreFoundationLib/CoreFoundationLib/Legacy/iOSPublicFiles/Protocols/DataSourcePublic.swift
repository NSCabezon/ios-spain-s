
public protocol DataSourcePublic: AnyObject {
    associatedtype T
    func getType() -> T?
    func load(baseUrl: String)
    func load(baseUrl: String, publicLanguage: PublicLanguage?)
    func buildLocalizedPath(baseURL: String) -> String
    func remove()
    
}
