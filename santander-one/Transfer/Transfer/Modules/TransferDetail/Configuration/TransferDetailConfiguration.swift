//
//  EmittedTransferDetailConfiguration.swift
//  Account
//
//  Created by Alvaro Royo on 17/6/21.
//

import CoreFoundationLib
import PdfCommons

public protocol TransferDetailConfigurationProtocol {}

public struct TransferDetailConfiguration {
    public var maxViewsNotExpanded = 3
    public var config = [TransferDetailConfigurationProtocol?]()
    public var isExpanded: Bool = true
    public var transferType: TransferDetailType
    public init(transferType: TransferDetailType) {
        self.transferType = transferType
    }
}

extension TransferDetailConfiguration {
    public struct Amount: TransferDetailConfigurationProtocol {
        public let amount: AmountEntity?
        public let concept: String?
        
        public init(amount: AmountEntity?, concept: String?) {
            self.amount = amount
            self.concept = concept
        }
        
        public var view: UIView {
            let amountView = AmountEmittedTransferView(frame: .zero)
            amountView.setAmount(amount)
            amountView.setConcept(concept)
            amountView.borders(for: [.top, .left, .right], color: .mediumSkyGray)
            return amountView
        }
    }
    
    public struct DestinationAccount: TransferDetailConfigurationProtocol {
        public let beneficiary: String?
        public let iban: String?
        public let bankIconUrl: String?
        
        public init(beneficiary: String?, iban: String?, bankIconUrl: String?) {
            self.beneficiary = beneficiary
            self.iban = iban
            self.bankIconUrl = bankIconUrl
        }
        
        public var view: UIView {
            let destination = DestinationEmittedTransferView(frame: .zero)
            destination.borders(for: [.left, .right], color: .mediumSkyGray)
            destination.set(beneficiary: beneficiary)
            destination.set(account: iban)
            destination.set(bankIconUrl: bankIconUrl)
            return destination
        }
    }
    
    public struct OriginAccount: TransferDetailConfigurationProtocol {
        public let title: String
        public let beneficiary: String?
        public let balance: String?
        let accessibilityIdentifier: String

        public init(title: String, beneficiary: String?, balance: String?, accessibilityIdentifier: String) {
            self.title = title
            self.beneficiary = beneficiary
            self.balance = balance
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
        public var view: SetLastRowProtocol {
            let defaultView = DefaultEmittedTransferView(frame: .zero)
            defaultView.set(title: title)
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.santander(size: 14)]
            let subtitle = NSMutableAttributedString(string: beneficiary ?? "",
                                                     attributes: nil)
            subtitle.append(NSMutableAttributedString(string: balance ?? "",
                                                      attributes: attributes))
            defaultView.set(content: subtitle, accessibilityIdentifier: self.accessibilityIdentifier)
            defaultView.borders(for: [.left, .right], color: .mediumSkyGray)
            return defaultView
        }
    }
    
    public struct DefaultViewConfig: TransferDetailConfigurationProtocol {
        public let title: String
        public let content: LocalizedStylableText
        let accessibilityIdentifier: String
        
        public init?(title: String, localized content: LocalizedStylableText?, accessibilityIdentifier: String) {
            guard let content = content else { return nil }
            self.title = title
            self.content = content
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
        public init?(title: String, content: String?, accessibilityIdentifier: String) {
            guard let content = content else { return nil }
            self.title = title
            self.content = localized(content)
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
        public var view: SetLastRowProtocol {
            let defaultView = DefaultEmittedTransferView(frame: .zero)
            defaultView.set(title: title)
            defaultView.set(content: content, accessibilityIdentifier: self.accessibilityIdentifier)
            defaultView.borders(for: [.left, .right], color: .mediumSkyGray)
            return defaultView
        }
    }
    
    public struct DefaultWithSubtitleViewConfig: TransferDetailConfigurationProtocol {
        public let title: String
        public let subtitle: String
        public let content: LocalizedStylableText
        let accessibilityIdentifier: String
        
        public init?(title: String, localized content: LocalizedStylableText?, subtitle: String, accessibilityIdentifier: String) {
            guard let content = content else { return nil }
            self.title = title
            self.content = content
            self.subtitle = subtitle
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
        public init?(title: String, content: String?, subtitle: String, accessibilityIdentifier: String) {
            guard let content = content else { return nil }
            self.title = title
            self.content = localized(content)
            self.subtitle = subtitle
            self.accessibilityIdentifier = accessibilityIdentifier
        }
        
        public var view: SetLastRowProtocol {
            let defaultView = DefaultWithSubtitleView(frame: .zero)
            defaultView.set(title: title)
            defaultView.set(content: content, accessibilityIdentifier: self.accessibilityIdentifier)
            defaultView.set(subtitle: subtitle)
            defaultView.borders(for: [.left, .right], color: .mediumSkyGray)
            return defaultView
        }
    }
    
    static func receivedConfigurationFrom(_ transfer: TransferViewModel) -> TransferDetailConfiguration {
        var detailConfiguration = TransferDetailConfiguration(
            transferType: TransferDetailType.received(
                transfer: transfer.transfer as? TransferReceivedEntity,
                fromAccount: transfer.from,
                account: transfer.account
            )
        )
        detailConfiguration.config.append(TransferDetailConfiguration.Amount(
            amount: transfer.transfer.amountEntity,
            concept: nil
        ))
        if let concept = transfer.transfer.concept {
            detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
                             title: "deliveryDetails_label_concept",
                             localized: localized(concept.camelCasedString),
                             accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.concept
                         ))
        }
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
             title: "deliveryDetails_label_type",
             localized: localized("deliveryDetails_label_receiveTransfer"),
             accessibilityIdentifier: TransferReceivedDetailAccessibilityIdentifier.transferReceivedLabelTypeValue
         ))
        let receivedTransfer = transfer.transfer as? TransferReceivedEntity
        let aliasAccountBeneficiary = receivedTransfer?.aliasAccountBeneficiary ?? ""
        let amount = receivedTransfer?.balanceEntity.getStringValue() ?? ""
        detailConfiguration.config.append(TransferDetailConfiguration.OriginAccount(
             title: "deliveryDetails_label_destinationAccounts",
             beneficiary: aliasAccountBeneficiary,
             balance: " (\(amount))",
             accessibilityIdentifier: TransferReceivedDetailAccessibilityIdentifier.transferReceivedLabelOriginAccount
         ))
        let operationDate = (transfer.transfer as? TransferReceivedEntity)?.operationDate
        let date = dateToString(date: operationDate, outputFormat: .dd_MMM_yyyy)
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
             title: "deliveryDetails_label_operationDate",
             content: date,
             accessibilityIdentifier: TransferReceivedDetailAccessibilityIdentifier.operationDate
         ))
        let valueDate = (transfer.transfer as? TransferReceivedEntity)?.valueDate
        let valueDateString = dateToString(date: valueDate, outputFormat: .dd_MMM_yyyy)
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
             title: "deliveryDetails_label_valueDate",
             content: valueDateString,
             accessibilityIdentifier: TransferReceivedDetailAccessibilityIdentifier.valueDate
         ))
        detailConfiguration.isExpanded = false
        return detailConfiguration
    }
}

public protocol SetLastRowProtocol: UIView {
    func setLastRow(_ last: Bool)
}
