
public struct BaseDataSourceParameters {
    public let relativeURL: String
    public let fileName: String
    
    public init(relativeURL: String, fileName: String) {
        self.relativeURL = relativeURL
        self.fileName = fileName
    }
}
