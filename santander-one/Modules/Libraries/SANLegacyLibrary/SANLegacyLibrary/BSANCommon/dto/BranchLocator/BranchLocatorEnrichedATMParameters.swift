
public struct BranchLocatorEnrichedATMParameters: Codable {
    public let branches: [BranchLocatorATMDTO]
    public init(branches: [BranchLocatorATMDTO]) {
        self.branches = branches
    }
}
