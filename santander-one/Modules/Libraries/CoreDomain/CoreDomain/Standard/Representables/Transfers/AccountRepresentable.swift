//
//  AccountRepresentable.swift
//  CoreFoundationLib
//
//  Created by José María Jiménez Pérez on 27/7/21.
//

public protocol AccountRepresentable: GlobalPositionProductIdentifiable {
    var currencyName: String? { get }
    var alias: String? { get }
    var currentBalanceRepresentable: AmountRepresentable? { get }
    var ibanRepresentable: IBANRepresentable? { get }
    var contractNumber: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var isMainAccount: Bool? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var getIBANShort: String { get }
    var getIBANPapel: String { get }
    var getIBANString: String { get }
    var situationType: String? { get }
    var availableAmountRepresentable: AmountRepresentable? { get }
    var availableNoAutAmountRepresentable: AmountRepresentable? { get }
    var overdraftRemainingRepresentable: AmountRepresentable? { get }
    var earningsAmountRepresentable: AmountRepresentable? { get }
    var productSubtypeRepresentable: ProductSubtypeRepresentable? { get }
    var countervalueCurrentBalanceAmountRepresentable: AmountRepresentable? { get }
    var countervalueAvailableNoAutAmountRepresentable: AmountRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var tipoSituacionCto: String? { get }
    func equalsTo(other: AccountRepresentable?) -> Bool
}

public extension AccountRepresentable {
    var situationType: String? { return nil }
    
    func equalsTo(other: AccountRepresentable?) -> Bool {
        guard let other = other else { return false }
        return self.contractRepresentable?.bankCode == other.contractRepresentable?.bankCode &&
        self.contractRepresentable?.branchCode == other.contractRepresentable?.branchCode &&
        self.contractRepresentable?.contractNumber == other.contractRepresentable?.contractNumber &&
        self.contractRepresentable?.product == other.contractRepresentable?.product
    }
    
    var availableAmount: AmountRepresentable? { return self.currentBalanceRepresentable }

    var countervalueAvailableNoAutAmountRepresentable: AmountRepresentable? {
        return nil
    }
}

// MARK: GlobalPositionProductRepresentable
public extension AccountRepresentable {
    var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    var boxType: UserPrefBoxType {
        return .account
    }
}
