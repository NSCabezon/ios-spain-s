import SANLegacyLibrary

struct BlockCardConfirm {
    private(set) var blockCardConfirmDTO: BlockCardConfirmDTO
    
    static func create(_ from: BlockCardConfirmDTO) -> BlockCardConfirm {
        return BlockCardConfirm(dto: from)
    }
    
    internal init(dto: BlockCardConfirmDTO) {
        blockCardConfirmDTO = dto
    }
}

extension BlockCardConfirm: OperativeParameter {}
