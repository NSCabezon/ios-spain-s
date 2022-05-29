import CoreFoundationLib

struct BizumContactListViewModel {
    let phone: String
    let thumbnailData: Data?
    let identifier: String
    let initials: String?
    let name: String?
    let isBizum: Bool
    let colorModel: ColorsByNameViewModel
    let surname: String?
    
    init(initials: String? = nil,
         name: String? = nil,
         phone: String,
         isBizum: Bool = false,
         colorModel: ColorsByNameViewModel = ColorsByNameViewModel(ColorsByNameEngineType.first),
         thumbnail: Data?) {
        self.identifier = name ?? phone
        self.initials = initials
        self.name = name
        self.phone = phone
        self.isBizum = isBizum
        self.colorModel = colorModel
        self.thumbnailData = thumbnail
        self.surname = ""
    }
}
