//
//  OnePastTransferViewModel.swift
//  Models
//
//  Created by Juan Diego Vázquez Moreno on 22/9/21.
//

import CoreDomain
import Foundation

public final class OnePastTransferViewModel {
    public var cardStatus: CardStatus
    public let transfer: TransferRepresentable
    public let avatar: OneAvatarViewModel
    private let dependenciesResolver: DependenciesResolver
    
    public init(
        cardStatus: CardStatus,
        transfer: TransferRepresentable,
        avatar: OneAvatarViewModel,
        dependenciesResolver: DependenciesResolver
    ) {
        self.cardStatus = cardStatus
        self.transfer = transfer
        self.avatar = avatar
        self.dependenciesResolver = dependenciesResolver
    }
}

public extension OnePastTransferViewModel {
    enum CardStatus {
        case inactive
        case selected
        case disabled
    }
    
    enum TransferType {
        case none
        case emited
        case received
    }
    
    enum TransferScheduleType {
        case normal
        case scheduled
        case periodic
    }
}

public extension OnePastTransferViewModel {
    
    var name: String {
        return self.transfer.name ?? ""
    }
    
    var shortIBAN: String? {
        return self.transfer.ibanRepresentable?.ibanShort(asterisksCount: 1)
    }
    
    var transferType: TransferType {
        switch self.transfer.typeOfTransfer {
        case .none:
            return .none
        case .emitted:
            return .emited
        case .received:
            return .received
        }
    }
    
    var transferScheduleType: TransferScheduleType {
        switch self.transfer.scheduleType {
        case .normal:
            return .normal
        case .scheduled:
            return .scheduled
        case .periodic:
            return .periodic
        default:
            return .normal
        }
    }
    
    var concept: String? {
        guard let noEmptyConcept = self.transfer.transferConcept, !noEmptyConcept.isEmpty else {
            return localized("onePay_label_notConcept")
        }
        return noEmptyConcept
    }
    
    var executedDateString: String? {
        guard let date = self.executedDate, let format = self.dateFormat else { return nil }
        return self.timeManager.toStringFromCurrentLocale(date: date, outputFormat: format)?.uppercased()
    }
    
    var dateDescription: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = self.dateFormat?.rawValue
        guard let date = self.executedDate else { return nil }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
    
    var bankLogoURL: String? {
        let baseURLProvider: BaseURLProvider = self.dependenciesResolver.resolve()
        guard let entityCode = self.transfer.ibanRepresentable?.getEntityCode(offset: 4),
              let countryCode = self.transfer.ibanRepresentable?.countryCode,
              let baseURL = baseURLProvider.baseURL
        else { return nil }
        
        return String(format: "%@%@/%@_%@%@",
                      baseURL,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
}

private extension OnePastTransferViewModel {
    var executedDate: Date? {
        self.transfer.transferExecutedDate
    }
    
    var timeManager: TimeManager {
        return dependenciesResolver.resolve()
    }
    
    var dateFormat: TimeFormat? {
        guard let date = self.executedDate else { return nil }
        return (date.isSameYear(than: Date())) ? .d_MMM : .d_MMM_yy
    }
}
