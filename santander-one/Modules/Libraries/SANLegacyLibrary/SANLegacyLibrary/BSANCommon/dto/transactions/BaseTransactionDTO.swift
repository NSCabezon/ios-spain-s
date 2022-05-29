import Foundation

public protocol BaseTransactionDTO: Codable {
	var operationDate: Date? { get }
	var amount: AmountDTO? { get }
	var description: String? { get }
}

