import CoreDomain
import CoreFoundationLib
import CoreDomain

struct PGClassicTableViewCellInfo {
    let header: PGClassicGeneralHeaderInfo?
    let cellInfos: [PGCellInfo]
    let footer: PGClassicFooter
    let underCell: PGCellInfo?
    
    var hasFooter: Bool {
        switch footer {
        case .none:
            return false
        case .always, .custom:
            return true
        case .onlyWhenOpened:
            return header?.open ?? false
        case .onlyWhenClosed:
            return !(header?.open ?? true)
        }
    }
    
    init(header: PGClassicGeneralHeaderInfo?, cellInfos: [PGCellInfo], footer: PGClassicFooter = .none, underCell: PGCellInfo?) {
        self.header = header
        self.cellInfos = cellInfos
        self.footer = footer
        self.underCell = underCell
    }
}

enum PGClassicFooter: Equatable {
    case none
    case always(GeneralFooterInfo)
    case onlyWhenOpened(GeneralFooterInfo)
    case onlyWhenClosed(GeneralFooterInfo)
    case custom(open: GeneralFooterInfo, closed: GeneralFooterInfo)
    
    static func == (lhs: PGClassicFooter, rhs: PGClassicFooter) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none), (.always, .always), (.onlyWhenOpened, .onlyWhenOpened), (.onlyWhenClosed, .onlyWhenClosed), (.custom, .custom):
            return true
        default:
            return false
        }
    }
}

struct PGClassicGeneralHeaderInfo {
    let title: String
    let imgName: String?
    var notification: Int?
    var open: Bool
    let productType: ProductTypeEntity
    let isCollapsable: Bool
    var canHaveNotifications: Bool {
        return [ProductTypeEntity.card, ProductTypeEntity.account].contains(productType)
            && notification != nil
            && (notification ?? 0) > 0
    }
}
