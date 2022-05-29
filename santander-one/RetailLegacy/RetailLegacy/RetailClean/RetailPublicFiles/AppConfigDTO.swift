//

import Foundation

public struct AppConfigDTO: Codable {

    var defaultConfig: [String: String]?
    var versions: [String: [String: String]]?

    public var getDefaultConfig: [String: String]? {
        return defaultConfig
    }

    public var getVersions: [String: [String: String]]? {
        return versions
    }
    
    public var getStringRepresentation: String {
        return "\(defaultConfig?.description ?? "")\(versions?.description ?? "")}"
    }
}
