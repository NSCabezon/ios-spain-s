import Foundation

public enum BillStatus: Int, Codable {
    
    case unknown
    case canceled
    case applied
    case returned
    case pendingToApply
    case pendingOfDate
    case pendingToResolve
    
    public init(from string: String) {
        switch string {
        case "ANU": self = .canceled
        case "APL": self = .applied
        case "DEV": self = .returned
        case "PAP": self = .pendingToApply
        case "PTF": self = .pendingOfDate
        case "PTR": self = .pendingToResolve
        default: self = .unknown
        }
    }
    
    public var value: String {
        switch self {
        case .unknown:
            return ""
        case .canceled:
            return "ANU"
        case .applied:
            return "APL"
        case .returned:
            return "DEV"
        case .pendingToApply:
            return "PAP"
        case .pendingOfDate:
            return "PTF"
        case .pendingToResolve:
            return "PTR"
        }
    }
}

public struct BillDTO: Codable {
    
    public let name: String
    public let holder: String
    public let status: BillStatus
    public let codProd: String
    public let codSubtypeProd: String
    public let paymentOrderCode: String
    public let creditorAccount: String
    public let creditorCenterId: String
    public let creditorCompanyId: String
    public let debtorCompanyId: String
    public let debtorAccount: String
    public let expirationDate: Date
    public let idban: String
    public let gauDate: Date
    public let pagDate: Date
    public let imporDV: String
    public let company: CentroDTO
    public let amount: AmountDTO
    public let code: String
    public let tipauto: String
    public let cdinaut: String
    
    public init?(name: String,
                 holder: String,
                 state: String,
                 codProd: String,
                 codSubtypeProd: String,
                 paymentOrderCode: String,
                 creditorAccount: String,
                 creditorCenterId: String,
                 creditorCompanyId: String,
                 debtorCompanyId: String,
                 debtorAccount: String,
                 expirationDate: Date,
                 idban: String,
                 gauDate: Date,
                 pagDate: Date,
                 imporDV: String,
                 company: CentroDTO,
                 amount: AmountDTO,
                 code: String,
                 tipauto: String,
                 cdinaut: String) {
        self.name = name
        self.holder = holder
        self.status = BillStatus(from: state)
        self.codProd = codProd
        self.codSubtypeProd = codSubtypeProd
        self.paymentOrderCode = paymentOrderCode
        self.creditorAccount = creditorAccount
        self.creditorCenterId = creditorCenterId
        self.creditorCompanyId = creditorCompanyId
        self.debtorCompanyId = debtorCompanyId
        self.debtorAccount = debtorAccount
        self.expirationDate = expirationDate
        self.idban = idban
        self.gauDate = gauDate
        self.pagDate = pagDate
        self.imporDV = imporDV
        self.company = company
        self.amount = amount
        self.code = code
        self.tipauto = tipauto
        self.cdinaut = cdinaut
    }
}

extension BillDTO: Equatable {
    
    public static func == (lhs: BillDTO, rhs: BillDTO) -> Bool {
        return lhs.name == rhs.name
        && lhs.holder == rhs.holder
        && lhs.status == rhs.status
        && lhs.codProd == rhs.codProd
        && lhs.codSubtypeProd == rhs.codSubtypeProd
        && lhs.paymentOrderCode == rhs.paymentOrderCode
        && lhs.creditorAccount == rhs.creditorAccount
        && lhs.creditorCenterId == rhs.creditorCenterId
        && lhs.creditorCompanyId == rhs.creditorCompanyId
        && lhs.debtorAccount == rhs.debtorAccount
        && lhs.debtorCompanyId == rhs.creditorCompanyId
        && lhs.expirationDate == rhs.expirationDate
        && lhs.idban == rhs.idban
        && lhs.gauDate == rhs.gauDate
        && lhs.pagDate == rhs.pagDate
        && lhs.imporDV == rhs.imporDV
        && lhs.company == rhs.company
        && lhs.amount.value == rhs.amount.value
        && lhs.code == rhs.code
        && lhs.tipauto == rhs.tipauto
        && lhs.cdinaut == rhs.cdinaut
    }
}
