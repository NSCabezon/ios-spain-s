import SANLegacyLibrary

struct GlobalPosition {

    let globalPositionDTO: GlobalPositionDTO

    static func createFrom(dto: GlobalPositionDTO) -> GlobalPosition {
        return GlobalPosition(globalPositionDTO: dto)
    }

    private init(globalPositionDTO: GlobalPositionDTO) {
        self.globalPositionDTO = globalPositionDTO
    }

    var name: String {
        if let name = globalPositionDTO.clientNameWithoutSurname, !name.isEmpty {
            return name
        }
        return globalPositionDTO.clientName ?? ""
    }

    var userId: String {
        if let userDataDTO = globalPositionDTO.userDataDTO {
            let userType = userDataDTO.clientPersonType ?? ""
            let userF = userDataDTO.clientPersonCode ?? ""
            return userType + userF
        }
        return ""
    }
    
    var userKey: String {
        let userDo = UserDO(dto: globalPositionDTO.userDataDTO)
        return userDo.userKey ?? ""
    }
    
    var accounts: [Account]? {
        return globalPositionDTO.accounts?.map({Account.create($0)})
    }
}
