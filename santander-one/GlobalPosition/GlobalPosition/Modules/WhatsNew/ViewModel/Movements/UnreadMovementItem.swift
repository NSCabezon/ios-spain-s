import Foundation
import CoreFoundationLib

public struct UnreadMovementItem {
    let type: MovementType
    let date: Date?
    let concept: String?
    let amount: AmountEntity?
    let imageUrl: String
    let alias: String?
    let movementID: Int
    let shortContract: String
    var crossSelling: UnreadCrossSellingViewProtocol?
    let isFractionable: Bool
    
    var amountAttributedString: NSAttributedString? {
        guard let availableAmount: AmountEntity = amount else { return nil}
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 20.0)
        let amount = MoneyDecorator(availableAmount, font: font, decimalFontSize: 16.0)
        return amount.getFormatedCurrency()
    }
    
    init(concept: String?,
         date: Date?,
         amount: AmountEntity?,
         imageUrl: String,
         alias: String?,
         shortContract: String,
         type: MovementType,
         movementId: Int,
         crossSelling: UnreadCrossSellingViewProtocol,
         isFractional: Bool) {
        self.date = date
        self.concept = concept
        self.alias = alias
        self.shortContract = shortContract
        self.amount = amount
        self.imageUrl = imageUrl
        self.type = type
        self.movementID = movementId
        self.crossSelling = crossSelling
        self.isFractionable = isFractional
    }
    
    func getFractionalTitle() -> String {
        switch type {
        case .card: return "cards_tag_optionsFractionatePay"
        case .account: return "accounts_tag_optionsPostponePay"
        }
    }
}
