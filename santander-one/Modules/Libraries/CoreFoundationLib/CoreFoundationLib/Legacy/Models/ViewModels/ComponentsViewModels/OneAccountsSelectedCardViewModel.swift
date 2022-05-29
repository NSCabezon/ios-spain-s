//
//  OneAccountsSelectedCardViewModel.swift
//  Models
//
//  Created by David Gálvez Alonso on 01/09/2021.
//
import CoreDomain

public enum SendMoneyAmountToShow {
    case available
    case currentBalance
}

public final class OneAccountsSelectedCardViewModel {
    public var statusCard: StatusCard
    public let originAccount: AccountRepresentable
    public let originImage: String?
    private let amountToShow: SendMoneyAmountToShow
    public init(
        statusCard: StatusCard,
        originAccount: AccountRepresentable,
        originImage: String? = nil,
        amountToShow: SendMoneyAmountToShow = .currentBalance
    ) {
        self.statusCard = statusCard
        self.originAccount = originAccount
        self.originImage = originImage
        self.amountToShow = amountToShow
    }
    
    public var originTitle: String {
        return self.originAccount.alias?.camelCasedString ?? ""
    }
    
    public var originDescription: String {
        return self.originAccount.getIBANShort
    }
    
    public var originAmount: AmountRepresentable? {
        switch amountToShow {
        case .available: return self.originAccount.availableAmount
        case .currentBalance: return self.originAccount.currentBalanceRepresentable
        }
    }
    
    public var destinationTitle: String {
        guard case .expanded(let model) = self.statusCard else { return "" }
        return model.destinationAlias ?? ""
    }
    
    public var destinationDescription: String {
        guard case .expanded(let model) = self.statusCard else { return "" }
        return model.destinationDescription
    }
    
    public var destinationImage: String? {
        guard case .expanded(let model) = self.statusCard else { return nil }
        return model.destinationImage
    }
    
    public var destinationCountry: String {
        guard case .expanded(let model) = self.statusCard else { return "" }
        return model.destinationCountry
    }

    public enum StatusCard: Equatable {
        case expanded(OneAccountsSelectedCardExpandedViewModel)
        case contracted
        public static func == (lhs: OneAccountsSelectedCardViewModel.StatusCard, rhs: OneAccountsSelectedCardViewModel.StatusCard) -> Bool {
            switch (lhs, rhs) {
            case (.expanded, .expanded):
                return true
            case (.contracted, .contracted):
                return true
            default:
                return false
            }
        }
    }
}

public struct OneAccountsSelectedCardExpandedViewModel {
    let destinationIban: IBANRepresentable
    let destinationImage: String?
    let destinationAlias: String?
    let destinationCountry: String
    
    public init(
        destinationIban: IBANRepresentable,
        destinationImage: String? = nil,
        destinationAlias: String?,
        destinationCountry: String
    ) {
        self.destinationIban = destinationIban
        self.destinationImage = destinationImage
        self.destinationAlias = destinationAlias
        self.destinationCountry = destinationCountry
    }
    
    var destinationDescription: String {
        return self.destinationIban.ibanShort(asterisksCount: 1)
    }
}
