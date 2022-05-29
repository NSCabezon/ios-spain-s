//
//  BizumSendMoneySummaryViewModel.swift
//
//  Created by Jose C. Yebes on 29/09/2020.
//
import Foundation
import CoreFoundationLib
import Operative

struct OperativeSummaryBizumViewModel {
    let header: OperativeSummaryStandardHeaderViewModel
    let bodyItems: [BizumSummaryItem]
    let bodyActionItems: [OperativeSummaryStandardBodyActionViewModel]
    let footerItems: [OperativeSummaryStandardFooterItemViewModel]
    
    public init(header: OperativeSummaryStandardHeaderViewModel, bodyItems: [BizumSummaryItem], bodyActionItems: [OperativeSummaryStandardBodyActionViewModel], footerItems: [OperativeSummaryStandardFooterItemViewModel]) {
        self.header = header
        self.bodyItems = bodyItems
        self.bodyActionItems = bodyActionItems
        self.footerItems = footerItems
    }
}

// Mixed item to fill custom bizum summary body
public struct BizumSummaryItem: Identifiable {
    public enum Position {
        case unknown
        case last
    }
    public var title: String
    public var id: Int // Position. We need a value to work as identifier, so we can adopts Identifiable
    public var position: Position
    public var metadata: Metadata
    
    public init(title: String, identifier: Int, position: Position = .unknown, metadata: Metadata) {
        self.title = title
        self.id = identifier
        self.position = position
        self.metadata = metadata
    }
}

extension BizumSummaryItem {
    public enum Metadata {
        case standard(data: OperativeSummaryBizumBodyItemViewModel)
        case recipients(list: [BizumSummaryRecipientItemViewModel])
        case multimedia(data: BizumSummaryMultimediaViewModel)
        case organization(data: BizumSummaryOrganizationViewModel)
    }
}

public struct BizumSummaryMultimediaViewModel {
    var imageText: String?
    var image: Data?
    var noteIcon: UIImage?
    var note: String?
}

public struct OperativeSummaryBizumBodyItemViewModel {
    public let subTitle: NSAttributedString
    public let info: String?
    public let accessibilityIdentifier: String?
    
    public init(subTitle: NSAttributedString, info: String? = nil, accessibilityIdentifier: String? = nil) {
        self.subTitle = subTitle
        self.info = info
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public init(subTitle: String, info: String? = nil, accessibilityIdentifier: String? = nil) {
        self.subTitle = NSAttributedString(string: subTitle)
        self.info = info
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

public struct BizumSummaryRecipientItemViewModel {
    
    public let name: String
    public let status: String
    public let amount: AmountEntity?
    public let accessibilityIdentifier: String?
    
    var amountAttributeString: NSAttributedString? {
        guard let amount = self.amount else { return nil }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 14)
        let decorator = MoneyDecorator(amount, font: font, decimalFontSize: 14.0)
        return decorator.getFormatedCurrency()
    }
}

public struct BizumSummaryOrganizationViewModel: BizumNGOProtocol {
    public let name: String
    public let alias: String
    public let identifier: String
    public var colorsByNameViewModel: ColorsByNameViewModel?
    private let baseUrl: String?
    
    public init(name: String, alias: String, identifier: String, baseUrl: String?, colorsByNameViewModel: ColorsByNameViewModel? = nil) {
        self.name = name
        self.alias = alias
        self.identifier = identifier
        self.baseUrl = baseUrl
        self.colorsByNameViewModel = colorsByNameViewModel
    }
    
    public var avatarColor: UIColor {
        return self.colorsByNameViewModel?.color ?? UIColor()
    }
    
    public var avatarName: String {
        return self.name
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
    
    private var identifierFormatted: String {
        return self.identifier.replacingOccurrences(of: "+", with: "")
    }
    
    public var iconUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        return String(format: "%@RWD/ongs/iconos/%@.png", baseUrl, self.identifierFormatted)
    }
}

struct BizumSummaryMultimediaItemViewModel {
    let imageSize: CGSize
    let topMargin: CGFloat
    let image: UIImage?
    let text: String
}

struct BizumSummaryContactViewModel {
    
    enum SendStatus {
        case sent
        case invited
    }
    
    let contactName: String
    let amount: Double
    let status: SendStatus
    
}

struct SummaryFooterItemViewModel {
    let image: String
    let title: String
    let action: () -> Void
}

struct SummaryActionViewModel {
    let image: String
    let title: String
    let action: () -> Void
}

struct SummaryHeaderViewModel {
    let image: String
    let title: String
    let description: String
}
