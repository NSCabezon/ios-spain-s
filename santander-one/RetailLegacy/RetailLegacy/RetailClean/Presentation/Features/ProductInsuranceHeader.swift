import UIKit.UICollectionViewCell

class ProductInsuranceHeader {
    struct ExtraInfo {
        let insuranceFamily: String?
        let insuranceName: String?
        let info: InsuranceBottomInfo?
    }
    
    var extraInfo: ExtraInfo?
    let policy: String
    let shareDelegate: ShareInfoHandler?
    let copyTag: Int?
    let isBigSeparator: Bool
    var updateHeaderView: (() -> Void)?
    
    init(insuranceFamily: String?,
         insuranceName: String?,
         policy: String,
         info: InsuranceBottomInfo?,
         copyTag: Int?,
         isBigSeparator: Bool,
         shareDelegate: ShareInfoHandler?) {
        
        self.extraInfo = ExtraInfo(insuranceFamily: insuranceFamily, insuranceName: insuranceName, info: info)
        self.policy = policy
        self.copyTag = copyTag
        self.shareDelegate = shareDelegate
        self.isBigSeparator = isBigSeparator
    }
}

enum InsuranceBottomInfo {
    case savings(amount: Amount)
    case protection(attributeTitle: String, attributeValue: String)
    case none
}
