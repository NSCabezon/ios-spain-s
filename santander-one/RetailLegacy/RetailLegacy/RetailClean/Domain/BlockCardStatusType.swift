import CoreDomain

enum BlockCardStatus: Int {
    case stolen
    case deterioration
}

struct BlockCardStatusType {
    private(set) var status: BlockCardStatus
    
    private init(blockCardStatus: BlockCardStatus) {
        self.status = blockCardStatus
    }
    
    static func create(_ blockCardStatus: BlockCardStatus) -> BlockCardStatusType {
        return BlockCardStatusType(blockCardStatus: blockCardStatus)
    }
    
    var getCardBlockType: CardBlockType {
        switch status {
        case .stolen:
            return CardBlockType.stolen
        case .deterioration:
            return CardBlockType.deterioration
        }
    }
}

extension BlockCardStatusType: OperativeParameter {}
