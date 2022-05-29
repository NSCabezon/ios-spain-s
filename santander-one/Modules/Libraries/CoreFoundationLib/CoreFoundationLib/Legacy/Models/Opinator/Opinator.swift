import Foundation

public struct RegularOpinatorInfoEntity: OpinatorInfoRepresentable {
    public let titleKey: String
    public let endPoint: String
    public let params: [OpinatorParameter]
}

public extension RegularOpinatorInfoEntity {
    init(titleKey: String = "toolbar_title_improve", path: String, params: [OpinatorParameter] = []) {
        self.titleKey = titleKey
        self.endPoint = path
        self.params = params + [DomainOpinatorParameter.userId, DomainOpinatorParameter.appVersion, DomainOpinatorParameter.language, DomainOpinatorParameter.browser, DomainOpinatorParameter.devicemodel, DomainOpinatorParameter.os]
    }
}

public protocol OpinatorParameter {
    var key: String { get }
}

public enum DomainOpinatorParameter: String {
    case userId = "id"
    case appVersion = "carry_appVersion"
    case language = "carry_language"
    case browser = "carry_browser"
    case devicemodel = "carry_devicemodel"
    case os = "carry_os"
}

extension DomainOpinatorParameter: OpinatorParameter {
   public var key: String {
        return rawValue
    }
}

public enum PresentationOpinatorParameter: String {
    case codGest
}

extension PresentationOpinatorParameter: OpinatorParameter {
    public var key: String {
        return rawValue
    }
}

public protocol OpinatorInfoRepresentable {
    var titleKey: String { get }
    var endPoint: String { get }
    var params: [OpinatorParameter] { get }
}

public protocol OpinatorInfoOptionProtocol {
    var baseUrl: String { get }
}
