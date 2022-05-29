import Foundation

public protocol TransactionModelProtocol {
    var transactionType: String {get}
    var id: String {get}
    var productId: String {get}
    var userId: String {get}
    var date: Date {get}
    var amount: Int64 {get}
    var currency: String {get}
    var description: String {get}
    var read: Int {get}
    var bankCode: String {get}
    var branchCode: String {get}
    var product: String {get}
    var contractnumber: String {get}
    var annotationDate: Date {get}
    var valueDate: Date {get}
    var transactionDay: String {get}
    var transactionNumber: String {get}}

public struct TransactionModel: TransactionModelProtocol {
    public let transactionType: String
    public let id: String
    public let productId: String
    public let userId: String
    public let date: Date
    public let amount: Int64
    public let currency: String
    public let description: String
    public let read: Int
    public let bankCode: String
    public let branchCode: String
    public let product: String
    public let contractnumber: String
    public let annotationDate: Date
    public let valueDate: Date
    public let transactionDay: String
    public let transactionNumber: String
    
    public init(model: TransactionModel, id: String) {
        self.transactionType = model.transactionType
        self.id = id
        self.productId = model.productId
        self.userId = model.userId
        self.date = model.date
        self.amount = model.amount
        self.currency = model.currency
        self.description = model.description
        self.read = model.read
        self.bankCode = model.bankCode
        self.branchCode = model.branchCode
        self.product = model.product
        self.contractnumber = model.contractnumber
        self.annotationDate = model.annotationDate
        self.valueDate = model.valueDate
        self.transactionDay = model.transactionDay
        self.transactionNumber = model.transactionNumber
    }
    
    public init(transactionType: String, id: String, productId: String, userId: String, date: Date, amount: Int64?, currency: String?, description: String?, read: Int, bankCode: String?, branchCode: String?, product: String?, contractnumber: String?, annotationDate: Date?, valueDate: Date?, transactionDay: String?, transactionNumber: String?) {
        self.transactionType = transactionType
        self.id = id
        self.productId = productId
        self.userId = userId
        self.date = date
        self.amount = amount ?? 0
        self.currency = currency ?? "EUR"
        self.description = description ?? ""
        self.read = read
        self.bankCode = bankCode ?? ""
        self.branchCode = branchCode ?? ""
        self.product = product ?? ""
        self.contractnumber = contractnumber ?? ""
        let today = Date()
        self.annotationDate = annotationDate ?? today
        self.valueDate = valueDate ?? today
        self.transactionDay = transactionDay ?? ""
        self.transactionNumber = transactionNumber ?? ""
    }
}
