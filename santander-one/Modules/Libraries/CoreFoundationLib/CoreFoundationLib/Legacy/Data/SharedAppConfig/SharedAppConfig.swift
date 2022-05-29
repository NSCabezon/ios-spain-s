public struct SharedAppConfig: Codable {
    public var isEnabledCounterValue: Bool?
    public var isEnabledCheckSca: Bool?
    public var managersSantanderPersonal: [String]?
    
    public init() {}
    
    public init(isEnabledCounterValue: Bool?,
                isEnabledCheckSca: Bool?,
                managersSantanderPersonal: [String]?) {
        self.isEnabledCounterValue = isEnabledCounterValue
        self.isEnabledCheckSca = isEnabledCheckSca
        self.managersSantanderPersonal = managersSantanderPersonal
        
    }
}
