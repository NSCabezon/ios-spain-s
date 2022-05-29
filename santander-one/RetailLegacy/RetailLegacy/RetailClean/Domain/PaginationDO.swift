import SANLegacyLibrary

struct PaginationDO {
    private(set) var dto: PaginationDTO
    var endList: Bool {
        get {
            return dto.endList
        }
        set {
            dto.endList = newValue
        }
    }

    init?(dto: PaginationDTO?) {
        guard let dto = dto else {
            return nil
        }
        self.dto = dto
    }
}
