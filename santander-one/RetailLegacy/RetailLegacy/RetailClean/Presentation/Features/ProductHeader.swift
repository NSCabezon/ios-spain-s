//
import CoreDomain
import Foundation

struct ProductHeader: ProductHeaderCompatible {
    let title: String
    let subtitle: String
    let styleSubtitle: LocalizedStylableText?
    let amount: Amount?
    let pendingText: LocalizedStylableText?
    let isPending: Bool
    let isCopyButtonAvailable: Bool?
    let copyTag: Int?
    let isBigSeparator: Bool
    let copyButtonCoachmarkId: CoachmarkIdentifier?
    let shareDelegate: ShareInfoHandler?
    enum AmountFormat {
        case short, long
    }
    var amountFormat: AmountFormat = .short
    
    init(title: String, subtitle: String, amount: Amount?, pendingText: LocalizedStylableText?, isPending: Bool, isCopyButtonAvailable: Bool?, copyTag: Int?, isBigSeparator: Bool, copyButtonCoachmarkId: CoachmarkIdentifier? = nil, shareDelegate: ShareInfoHandler?, amountFormat: AmountFormat = .short) {
        self.title = title
        self.subtitle = subtitle
        self.styleSubtitle = nil
        self.amount = amount
        self.pendingText = pendingText
        self.isPending = isPending
        self.isCopyButtonAvailable = isCopyButtonAvailable
        self.copyTag = copyTag
        self.isBigSeparator = isBigSeparator
        self.copyButtonCoachmarkId = copyButtonCoachmarkId
        self.shareDelegate = shareDelegate
        self.amountFormat = amountFormat
    }
    
    init(title: String, styleSubtitle: LocalizedStylableText, amount: Amount?, pendingText: LocalizedStylableText?, isPending: Bool, isCopyButtonAvailable: Bool?, copyTag: Int?, isBigSeparator: Bool, copyButtonCoachmarkId: CoachmarkIdentifier? = nil, shareDelegate: ShareInfoHandler?, amountFormat: AmountFormat = .short) {
        self.title = title
        self.subtitle = styleSubtitle.text
        self.styleSubtitle = styleSubtitle
        self.amount = amount
        self.pendingText = pendingText
        self.isPending = isPending
        self.isCopyButtonAvailable = isCopyButtonAvailable
        self.copyTag = copyTag
        self.isBigSeparator = isBigSeparator
        self.copyButtonCoachmarkId = copyButtonCoachmarkId
        self.shareDelegate = shareDelegate
        self.amountFormat = amountFormat
    }
}
