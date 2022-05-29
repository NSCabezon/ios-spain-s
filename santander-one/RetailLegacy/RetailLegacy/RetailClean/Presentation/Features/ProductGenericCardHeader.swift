//

import Foundation

enum CardState {
    case active
    case disabled
    case blocked
}

struct ProductGenericCardHeader {
    let title: String
    let subtitle: String
    let amount: String
    let cardImage: String
    let action: (() -> Void)?
    let imageLoader: ImageLoader
    let isActive: Bool
    let amountTitleText: LocalizedStylableText?
    let isInfoAvailable: Bool
    let cardState: CardState
    let cellEventsHandler: GenericCardCellEventsDelegate?
    let shareDelegate: ShareInfoHandler?
    let copyTag: Int?
    let amountLabelCoachmarkId: CoachmarkIdentifier?
}
