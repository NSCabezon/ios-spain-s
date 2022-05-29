public struct MifidEvaluatedDTO: Codable {
    public var client: ClientDTO?
    public var indClasFirma: Bool?
    public var testList: [MifidTestIndicatorDTO] = []

    public init() {}
}
