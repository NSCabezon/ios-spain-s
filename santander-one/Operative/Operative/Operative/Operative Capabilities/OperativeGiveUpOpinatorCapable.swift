import CoreFoundationLib

public protocol OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity { get }
}

public struct GiveUpOpinatorInfoEntity: OpinatorInfoRepresentable {
    public let titleKey: String
    public let endPoint: String
    public let params: [OpinatorParameter]
}

public extension GiveUpOpinatorInfoEntity {
    
    init(titleKey: String = "toolbar_title_improve", path: String, params: [OpinatorParameter] = []) {
        self.titleKey = titleKey
        self.endPoint = path
        self.params = params + [DomainOpinatorParameter.userId, DomainOpinatorParameter.appVersion, DomainOpinatorParameter.language, DomainOpinatorParameter.browser, DomainOpinatorParameter.devicemodel, DomainOpinatorParameter.os]
    }
}
