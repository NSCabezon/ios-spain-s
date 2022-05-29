public struct WebServicesUrl {
    public static let LOGIN = "oauth/password/token"
    public static let GET_INSURANCE_DATA = "insurances/contracts/%@"
    public static let GET_PARTICIPANTS = "insurances/policies/%@/participants"
    public static let GET_BENEFICIARIES = "insurances/policies/%@/beneficiaries"
    public static let GET_COVERAGES = "insurances/policies/%@/coverages"

    public var value: String

    public init(value: String) {
        self.value = value
    }

    public func getValue(_ args: [String]) -> String {
        return String(format: value, args)
    }
}
