import CoreFoundationLib

struct PullOffersConfigTip {
    let dto: PullOffersConfigTipDTO
    var title: String? {
        return dto.title
    }
    var desc: String? {
        return dto.desc
    }
    var icon: String? {
        return dto.icon
    }
    
    var offerId: String? {
        return dto.offerId
    }
}
