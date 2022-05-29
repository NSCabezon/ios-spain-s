import Foundation

public struct AppConfigEntity {

    let defaultConfig: [String: String]
    let versions: [String: [String: String]]
    
    public init(defaultConfig: [String: String], versions: [String: [String: String]]) {
        self.defaultConfig = defaultConfig
        self.versions = versions
    }

    public var getDefaultConfig: [String: String]? {
        return defaultConfig
    }

    public var getVersions: [String: [String: String]]? {
        return versions
    }
    
    public var getStringRepresentation: String {
        return "\(defaultConfig.description)\(versions.description)"
    }
}
