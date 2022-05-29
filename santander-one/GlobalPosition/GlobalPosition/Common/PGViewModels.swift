//
//  PGViewModels.swift
//  GlobalPosition
//
//  Created by Tania Castellano Brasero on 23/12/2019.
//

import CoreFoundationLib

public protocol PGGeneralCellViewConfigUseCase: UseCase<Any, PGGeneralCellViewModelProtocol?, StringErrorOutput> {
}

public struct PGGeneralCellViewModel: PGGeneralCellViewModelProtocol {
    public var title: String?
    public var subtitle: String?
    public var ammount: NSAttributedString?
    public var notification: Int?
    public var elem: Any?
    public init() {}
}

public protocol PGGeneralCellViewModelProtocol: ElementEntity {
    var title: String? { get }
    var subtitle: String? { get }
    var ammount: NSAttributedString? { get }
    var notification: Int? { get set }
}

struct PGGenericNotificationCellViewModel: PGGeneralCellViewModelProtocol {
    let title: String?
    let subtitle: String?
    let ammount: NSAttributedString?
    let elem: Any?
    var notification: Int?
    var discreteMode: Bool? = false
}

struct PGCardCellViewModel: PGGeneralCellViewModelProtocol {
    var title: String?
    var subtitle: String?
    var ammount: NSAttributedString?
    var notification: Int?
    var availableBalance: NSAttributedString?
    let imgURL: String
    let customFallbackImage: UIImage?
    let balanceTitle: String?
    let disabled: Bool
    let toActivate: Bool
    let elem: Any?
    var discreteMode: Bool? = false
    var cardType: CardType
}

enum CardType {
    case debit
    case credit
    case prepaid
    
    init(cardType: CardDOType) {
        switch cardType {
        case .credit:
            self = .credit
        case .debit:
            self = .debit
        case .prepaid:
            self = .prepaid
        }
    }
}

struct PGGenericCellViewModel: PGGeneralCellViewModelProtocol {
    var notification: Int?
    let title: String?
    let subtitle: String?
    let ammount: NSAttributedString?
    let elem: Any?
}

struct PGSmartGenericCellViewModel: PGGeneralCellViewModelProtocol {
    var notification: Int?
    let title: String?
    let subtitle: String?
    let ammount: NSAttributedString?
    let elem: Any?
    let producName: String?
    let basketName: String?
    var discreteMode: Bool? = false
}

struct PGStatedCellViewModel: PGGeneralCellViewModelProtocol {
    var notification: Int?
    var state: PGMovementsNoticesCellState
    let title: String?
    let subtitle: String?
    let ammount: NSAttributedString?
    let rows: [PGStatedCellViewModelRow]?
    let elem: Any?
}

enum PGStatedCellViewModelRow {
    case titleAmount(titleKey: String, amount: NSAttributedString?)
    case movements(number: Int)
}

struct PGMovementCellViewModel: PGGeneralCellViewModelProtocol {
    var notification: Int?
    var imNew: Bool
    let imLast: Bool
    let title: String?
    let subtitle: String?
    let ammount: NSAttributedString?
    let elem: Any?
}

enum PGMovementsNoticesCellState {
    case loading
    case noResults
    case none
}

struct PGInterventionFilterModel {
    var filter: PGInterventionFilter
    var selected: Bool
}

struct PGCellInfo {
    let cellClass: String
    let cellHeight: CGFloat
    let info: Any?
}
