//

import Foundation

public struct AppInfoDTO {
    
    private var versions = [String: [String: String]]()
    
    public init(versions: [String: [String: String]]) {
        self.versions = versions
    }
    
    public var getVersions: [String: [String: String]] {
        return versions
    }
    
    public var getStringRepresentation: String {
        return "\(versions.description)"
    }
}
