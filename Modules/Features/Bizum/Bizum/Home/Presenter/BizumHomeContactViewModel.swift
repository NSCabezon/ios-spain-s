import CoreFoundationLib

struct BizumHomeContactViewModel {
    let identifier: String?
    let initials: String?
    let name: String?
    let phone: String?
    let isRegisterInBizum: Bool
    let colorModel: ColorsByNameViewModel
}

extension BizumHomeContactViewModel: Hashable {
    static func == (lhs: BizumHomeContactViewModel, rhs: BizumHomeContactViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var hashValue: Int {
        if let identifier = identifier, let hash = Int(identifier) {
            return hash
        }
        return 0
    }
}
