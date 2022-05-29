import SANLegacyLibrary
import CoreDomain

public struct ManagerList {

    public var managers: [Manager] = []
    
    public init(managerListDTO: [ManagerDTO]) {
        self.managers = managerListDTO.map(Manager.init)
    }

    public mutating func addManager(manager: Manager) {
        managers.append(manager)
    }
}
