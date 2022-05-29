import CoreFoundationLib
import UI
import ESUI

enum BizumHomeOptionViewModel {
    case send
    case request
    case donation
    case qrCode
    case payGroup
    case fundMoneySent

    var title: LocalizedStylableText {
        switch self {
        case .send:
            return localized("bizum_button_sendMoney")
        case .request:
            return localized("bizum_button_askForMoney")
        case .donation:
            return localized("bizum_button_sendDonation")
        case .qrCode:
            return localized("bizum_button_codeQr")
        case .payGroup:
            return localized("bizum_button_payGroup")
        case .fundMoneySent:
            return localized("bizum_button_fundMoneySent")
        }
    }
    
    var subtitle: LocalizedStylableText {
        switch self {
        case .send:
            return localized("bizum_text_sendMoney")
        case .request:
            return localized("bizum_text_askForMoney")
        case .donation:
            return localized("bizum_text_sendDonation")
        case .qrCode:
            return localized("bizum_text_codeQr")
        case .payGroup:
            return localized("bizum_text_payGroup")
        case .fundMoneySent:
            return localized("bizum_text_fundMoneySent")
        }
    }
    
    var identifier: String {
        switch self {
        case .send:
            return "bizumBntSendMoney"
        case .request:
            return "bizumBntRequestMoney"
        case .donation:
            return "bizumBtnSendDonation"
        case .qrCode:
            return "bizumBntQRCode"
        case .payGroup:
            return localized("bizumBntPayGroup")
        case .fundMoneySent:
            return localized("bizumBntFundMoneySent")
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .send:
            return ESAssets.image(named: "icnSendRed")
        case .request:
            return ESAssets.image(named: "icnReceivedGreen")
        case .donation:
            return Assets.image(named: "icnDonations")
        case .qrCode:
            return ESAssets.image(named: "sliceQrCode")
        case .payGroup:
            return ESAssets.image(named: "icnPayGroup")
        case .fundMoneySent:
            return ESAssets.image(named: "icnFundSent")
        }
    }
}
