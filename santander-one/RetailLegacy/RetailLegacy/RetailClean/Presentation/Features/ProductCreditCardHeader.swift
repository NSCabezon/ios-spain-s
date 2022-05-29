//

import Foundation

struct ProductCreditCardHeader {
    let title: String
    let subtitle: String
    let amount: String?
    let availableDescription: LocalizedStylableText
    let availableAmount: LocalizedStylableText
    let limitAmount: LocalizedStylableText
    let cardImage: String
    let action: (() -> Void)?
    let imageLoader: ImageLoader
    let cardState: CardState
    let percentageBar: Float
    let cellEventsHandler: GenericCardCellEventsDelegate?
    let shareDelegate: ShareInfoHandler?
    let copyTag: Int?
}
