//

import Foundation

struct ProductAccountHeader: ProductHeaderCompatible {
    let title: String
    let subtitle: String
    let styleSubtitle: LocalizedStylableText?
    let amount: Amount?
    let realAmount: Amount?
    let pendingText: LocalizedStylableText?
    let isPending: Bool
    let isCopyButtonAvailable: Bool?
    let shareDelegate: ShareInfoHandler?
    let copyTag: Int?
    let isBigSeparator: Bool
    let copyButtonCoachmarkId: CoachmarkIdentifier?
    let cellEventsHandler: ProductAccountCollectionViewCellEventsDelegate?
    let styleAvailableAmountTitle: LocalizedStylableText?
    let styleRealAmountTitle: LocalizedStylableText?
    let styleRetentionsTitle: LocalizedStylableText?
    
    init(title: String,
         subtitle: String,
         amount: Amount?,
         realAmount: Amount?,
         pendingText: LocalizedStylableText?,
         isPending: Bool,
         isCopyButtonAvailable: Bool?,
         copyTag: Int?,
         isBigSeparator: Bool,
         cellEventsHandler: ProductAccountCollectionViewCellEventsDelegate?,
         copyButtonCoachmarkId: CoachmarkIdentifier? = nil,
         styleAvailableAmountTitle: LocalizedStylableText?,
         styleRealAmountTitle: LocalizedStylableText?,
         styleRetentionsTitle: LocalizedStylableText?,
         shareDelegate: ShareInfoHandler?) {
        
        self.title = title
        self.subtitle = subtitle
        self.styleSubtitle = nil
        self.amount = amount
        self.realAmount = realAmount
        self.pendingText = nil
        self.isPending = false
        self.isCopyButtonAvailable = isCopyButtonAvailable
        self.copyTag = copyTag
        self.isBigSeparator = isBigSeparator
        self.copyButtonCoachmarkId = copyButtonCoachmarkId
        self.cellEventsHandler = cellEventsHandler
        self.styleAvailableAmountTitle = styleAvailableAmountTitle
        self.styleRealAmountTitle = styleRealAmountTitle
        self.styleRetentionsTitle = styleRetentionsTitle
        self.shareDelegate = shareDelegate
    }
    
    init(title: String,
         styleSubtitle: LocalizedStylableText,
         amount: Amount?,
         realAmount: Amount?,
         pendingText: LocalizedStylableText?,
         isPending: Bool,
         isCopyButtonAvailable: Bool?,
         copyTag: Int?, isBigSeparator: Bool,
         cellEventsHandler: ProductAccountCollectionViewCellEventsDelegate?,
         copyButtonCoachmarkId: CoachmarkIdentifier? = nil,
         styleAvailableAmountTitle: LocalizedStylableText?,
         styleRealAmountTitle: LocalizedStylableText?,
         styleRetentionsTitle: LocalizedStylableText?,
         shareDelegate: ShareInfoHandler?) {
        
        self.title = title
        self.subtitle = styleSubtitle.text
        self.styleSubtitle = styleSubtitle
        self.amount = amount
        self.realAmount = realAmount
        self.pendingText = nil
        self.isPending = false
        self.isCopyButtonAvailable = isCopyButtonAvailable
        self.copyTag = copyTag
        self.isBigSeparator = isBigSeparator
        self.copyButtonCoachmarkId = copyButtonCoachmarkId
        self.cellEventsHandler = cellEventsHandler
        self.styleAvailableAmountTitle = styleAvailableAmountTitle
        self.styleRealAmountTitle = styleRealAmountTitle
        self.styleRetentionsTitle = styleRetentionsTitle
        self.shareDelegate = shareDelegate
    }
}
