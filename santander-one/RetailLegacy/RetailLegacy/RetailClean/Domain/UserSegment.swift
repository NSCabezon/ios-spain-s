import SANLegacyLibrary

struct UserSegment {

    private var userSegmentDTO: UserSegmentDTO

    static func createFromDTO(_ dto: UserSegmentDTO?) -> UserSegment? {
        if let dto = dto {
            return UserSegment(dto: dto)
        }
        return nil
    }

    private init(dto: UserSegmentDTO) {
        userSegmentDTO = dto
    }
    
    func isSmartColective() -> Bool {
        if let colectivo123Smart = userSegmentDTO.colectivo123Smart {
            return colectivo123Smart
        }
        return false
    }

    func isSmartFreeColective() -> Bool {
        if let colectivo123SmartFree = userSegmentDTO.colectivo123SmartFree {
            return colectivo123SmartFree
        }
        return false
    }
	
	func isProfesionalFreeColective() -> Bool {
        return userSegmentDTO.colectivoAutonomoFree ?? false
	}
	
	func isProfesionalPremium() -> Bool {
        return userSegmentDTO.colectivoAutonomoPrem ?? false
	}
    
    func belongsSmartCollective() -> Bool {
        return userSegmentDTO.indCollectiveS ?? false
            || userSegmentDTO.indCollectiveSFreelance ?? false
            || userSegmentDTO.indCollectiveSCompanies ?? false
            || userSegmentDTO.colectivo123Smart ?? false
            || userSegmentDTO.colectivo123SmartFree ?? false
            || userSegmentDTO.colectivoAutonomoPrem ?? false
            || userSegmentDTO.colectivoAutonomoFree ?? false
    }
}
