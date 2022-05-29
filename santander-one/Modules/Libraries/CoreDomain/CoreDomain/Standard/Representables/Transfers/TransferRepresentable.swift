//
//  TransferRepresentable.swift
//  CoreFoundationLib
//
//  Created by Juan Diego Vázquez Moreno on 23/9/21.
//

public enum TransferRepresentableType {
    case emitted
    case received
}

public enum TransferRepresentableScheduleType {
    case normal
    case scheduled
    case periodic
}

public enum TransactionStatusRepresentableType: String {
    case booked = "Booked"
    case pending = "Pending"
}

public protocol TransferRepresentable {
    var ibanRepresentable: IBANRepresentable? { get }
    var name: String? { get }
    var transferConcept: String? { get }
    var typeOfTransfer: TransferRepresentableType? { get }
    var scheduleType: TransferRepresentableScheduleType? { get }
    var amountRepresentable: AmountRepresentable? { get }
    var transferExecutedDate: Date? { get }
    var transferNumber: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var transferType: String? { get }
    var countryCode: String? { get }
    func lessThan(other: TransferRepresentable) -> Bool
    func equalTo(other: TransferRepresentable) -> Bool
}

public extension TransferRepresentable {
    func lessThan(other: TransferRepresentable) -> Bool {
        if let lhsDate = self.transferExecutedDate,
           let rhsDate = other.transferExecutedDate,
           lhsDate != rhsDate {
            return lhsDate < rhsDate
        }
        let lhsValue = (self.amountRepresentable?.value ?? 0.0)
        let rhsValue = (other.amountRepresentable?.value ?? 0.0)
        if lhsValue == rhsValue {
            return (self.name ?? "") > (other.name ?? "")
        } else {
            return lhsValue < rhsValue
        }
    }
    
    func equalTo(other: TransferRepresentable) -> Bool {
        let lhsValue = (self.amountRepresentable?.value ?? 0.0)
        let rhsValue = (other.amountRepresentable?.value ?? 0.0)
        guard let lhsDate = self.transferExecutedDate,
              let rhsDate = other.transferExecutedDate
        else { return lhsValue == rhsValue }
        return lhsDate == rhsDate && lhsValue == rhsValue
    }
    var transferType: String? { nil }
    var countryCode: String? { nil }
}
