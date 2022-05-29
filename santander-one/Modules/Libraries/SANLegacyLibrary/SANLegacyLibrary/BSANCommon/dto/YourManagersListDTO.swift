public struct YourManagersListDTO: Codable {
    public var managerList = [ManagerDTO]()
    public var description: String {
        return "YourManagersModel{ managerList= \(managerList) }"
    }
    
    public init () {}
}
