import CoreFoundationLib
import UI
import ESUI

enum BizumHomeOperationTypeViewModel {
    case donation
    case request
    case purchase
    case send
}

enum BizumHomeOperationTypeStateViewModel: String {
    case pendingValidation
    case validated
    case accepted
    case rejected
    case back
    case pending
    case denied
    case expired
    case canceled
    case error
    case pendingRegister
    case void
    case pendingResponse
    
    var color: UIColor {
        switch self {
        case .pendingValidation, .pending, .pendingRegister, .pendingResponse:
            return .santanderYellow
        case .rejected, .denied, .expired, .canceled, .error, .void:
            return .bostonRedLight
        case .back:
            return .darkTorquoise
        case .accepted, .validated:
            return .limeGreen
        }
    }
    
    var image: UIImage? {
        switch self {
        case .pendingValidation, .pending, .pendingRegister, .pendingResponse:
            return ESAssets.image(named: "icnPending")
        case .expired:
            return ESAssets.image(named: "icnClockRed20")
        case .rejected, .denied, .canceled, .error, .void:
            return ESAssets.image(named: "icnCloseOvalRed")
        case .accepted, .validated:
            return ESAssets.image(named: "icnCheckOvalLimeGreen20")
        case .back:
            return ESAssets.image(named: "icnMiniReturnedOvalGreen")
        }
    }
    
    var homeImage: UIImage? {
        switch self {
        case .pendingValidation, .pending, .pendingRegister, .pendingResponse:
            return ESAssets.image(named: "icnPendingPoint")
        case .expired:
            return ESAssets.image(named: "icnMiniClockDarkTurquoise")
        case .rejected, .denied, .canceled, .error, .void:
            return ESAssets.image(named: "icnMiniCancelHome")
        case .accepted, .validated:
            return ESAssets.image(named: "icnMiniCheckAccept")
        case .back:
            return ESAssets.image(named: "icnReturned")
        }
    }
}

enum BizumHomeOperationTypeEmissorViewModel {
    case received
    case send
}

struct BizumHomeOperationViewModel {
    let identifier: String?
    let date: String?
    let title: String?
    let subtitle: String?
    let amount: Double?
    let transactionType: BizumTransactionType
    let emmissorType: BizumHomeOperationTypeEmissorViewModel?
    let state: String?
    let stateType: BizumHomeOperationTypeStateViewModel?
    let isMultiple: Bool
    
    func moneyDecorated(_ font: UIFont) -> MoneyDecorator {
        return MoneyDecorator(AmountEntity(value: Decimal(self.amount ?? 0)), font: font, decimalFontSize: 13.0)
    }
}
