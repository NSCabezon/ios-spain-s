import CoreFoundationLib
import UI

struct BizumContactViewModel {
    let identifier: String?
    let initials: String?
    let name: String?
    let phone: String
    let colorModel: ColorsByNameViewModel?
    let tag: Int?
    let thumbnailData: Data?

    init(identifier: String?,
         initials: String?,
         name: String?,
         phone: String,
         colorModel: ColorsByNameViewModel? = nil,
         tag: Int? = nil, thumbnailData: Data?) {
        self.identifier = identifier
        self.initials = initials
        self.name = name
        self.phone = phone
        self.colorModel = colorModel
        self.tag = tag
        self.thumbnailData = thumbnailData
    }
}

extension BizumContactViewModel: Hashable {
    static func == (lhs: BizumContactViewModel, rhs: BizumContactViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var hashValue: Int {
        if let identifier = identifier, let hash = Int(identifier) {
            return hash
        }
        return 0
    }
}
