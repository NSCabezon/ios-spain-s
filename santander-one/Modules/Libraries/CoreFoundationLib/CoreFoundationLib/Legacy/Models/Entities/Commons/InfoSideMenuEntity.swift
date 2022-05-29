public protocol InfoSideMenuEntityRepresentable {
    var availableName: String? { get }
    var initials: String? { get }
}

public struct InfoSideMenuEntity: InfoSideMenuEntityRepresentable {
    public let availableName: String?
    public let initials: String?
    
    public init(availableName: String?, initials: String?) {
        self.availableName = availableName
        self.initials = initials
    }
}
