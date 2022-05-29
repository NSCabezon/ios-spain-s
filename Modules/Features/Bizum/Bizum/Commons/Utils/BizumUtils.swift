import CoreFoundationLib

final class BizumUtils {
    static func getAmountSign(_ type: BizumHomeOperationTypeViewModel?, emmissorType: BizumHomeOperationTypeEmissorViewModel?) -> Double {
        switch (type, emmissorType) {
        case (.donation, _), (.send, .send), (.request, .received), (.purchase, _):
            return -1
        case (.send, .received), (.send, .none), (.request, .send), (.request, .none), (.none, _):
            return 1
        }
    }

    static func getIdentifier(_ alias: String?, phone: String) -> String {
        if let alias = alias, !alias.isEmpty {
            return alias
        } else {
            return phone
        }
    }

    static func getTotalAmount(_ amount: Double, contacts: Int, transactionType: BizumTransactionType) -> AmountEntity {
        var totalAmount = amount * Double(contacts)
        if transactionType != BizumTransactionType.emittedRequest &&
            transactionType != BizumTransactionType.receiverSend {
            totalAmount.negate()
        }
        return AmountEntity(value: Decimal(totalAmount))
    }

    static func getEmissorType(phone: String, emitterId: String, receptorIds: [String]) -> BizumHomeOperationTypeEmissorViewModel? {
        if phone == emitterId {
            return  .send
        } else if receptorIds.contains(phone) {
            return .received
        } else {
            return .none
        }
    }
    
    static func getTransactionType(phone: String, emitterId: String, emitterType: BizumHomeOperationTypeViewModel) -> BizumTransactionType {
        let isEmitter: Bool = phone == emitterId
        switch (emitterType, isEmitter) {
        case (.donation, _):
            return .donation
        case (.purchase, _):
            return .purchase
        case (.request, true):
            return .emittedRequest
        case (.request, false):
            return .receiverRequest
        case (.send, true):
            return .emittedSend
        case (.send, false):
            return .receiverSend
        }
    }

    static func getViewModelStateType(_ stateType: BizumOperationStateEntity?) -> BizumHomeOperationTypeStateViewModel? {
        switch stateType {
        case .pendingValidation:
            return .pendingValidation
        case .validated:
            return .validated
        case .accepted:
            return .accepted
        case .rejected:
            return .rejected
        case .back:
            return .back
        case .pending:
            return .pending
        case .denied:
            return .denied
        case .expired:
            return .expired
        case .canceled:
            return .canceled
        case .error:
            return .error
        case .pendingRegister:
            return .pendingRegister
        case .pendingResponse:
            return .pendingResponse
        case .void:
            return .void
        case .none:
            return nil
        }
    }
    
    static func getViewModelType(_ type: BizumOperationTypeEntity?) -> BizumHomeOperationTypeViewModel? {
        switch type {
        case .donation:
            return .donation
        case .request:
            return .request
        case .purchase:
            return .purchase
        case .send:
            return .send
        case .none:
            return nil
        }
    }
    
    /// Returns a string with the following format: `bold (regular)`
    /// - Parameters:
    ///   - bold: The bold part of the string
    ///   - regular: The regular part of the string
    static func boldRegularAttributedString(bold: String, regular: String) -> NSAttributedString {
        let regularWithParenthesis = "(" + regular + ")"
        let builder = TextStylizer.Builder(fullText: bold + " " + regularWithParenthesis)
        let boldStyle = TextStylizer.Builder.TextStyle(word: bold)
        let regularStyle = TextStylizer.Builder.TextStyle(word: regularWithParenthesis)
        return builder.addPartStyle(part: boldStyle
                                        .setColor(.lisboaGray)
                                        .setStyle(.santander(family: .text, type: .bold, size: 14))
        ).addPartStyle(part: regularStyle
                        .setColor(.lisboaGray)
                        .setStyle(.santander(family: .text, size: 14))
        ).build()
    }
    
    /// Return attributted string with: `· bold`
    /// - Parameter bold: The bold string
    /// - Returns: The regular part of the string
    static func boldBulletAttributedString(_ bold: String) -> NSAttributedString {
        let bulletPoint = "·"
        let builder = TextStylizer.Builder(fullText: bulletPoint + "  " + bold)
        let boldStyle = TextStylizer.Builder.TextStyle(word: bold)
        let bulletStyle = TextStylizer.Builder.TextStyle(word: bulletPoint)
        return builder
            .addPartStyle(part: bulletStyle
                            .setColor(.bostonRedLight)
                            .setStyle(.santander(family: .text, type: .bold, size: 22)))
            .addPartStyle(part: boldStyle
                            .setColor(.lisboaGray)
                            .setStyle(.santander(family: .text, type: .bold, size: 14)))
            .build()
    }
}
