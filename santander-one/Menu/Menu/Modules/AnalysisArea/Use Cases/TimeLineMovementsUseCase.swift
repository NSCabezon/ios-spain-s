//
//  TimeLineMovementsUseCase.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 19/03/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public enum TimelineSearchDirection: String {
    case forward
    case backward
}

class TimeLineMovementsUseCase: UseCase<TimeLineMovementsInputUseCase, TimeLineMovementsOutputUseCase, StringErrorOutput> {
    
    private let managersProvider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    private var visibleAccountsAndHolder = [String]()
    private var timelineMovements: [SANLegacyLibrary.TimeLineMovementDTO] = [SANLegacyLibrary.TimeLineMovementDTO]()
    private var personBasicInfo: PersonBasicDataDTO?
    private var merger: GlobalPositionPrefsMergerEntity
    private var timeLineManager: BSANTimeLineManager
    private var offset: String?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.timeLineManager = managersProvider.getTimeLineMovementsManager()
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        self.merger = GlobalPositionPrefsMergerEntity(resolver: dependenciesResolver, globalPosition: globalPosition, saveUserPreferences: false)
    }
    
    override func executeUseCase(requestValues: TimeLineMovementsInputUseCase) throws -> UseCaseResponse<TimeLineMovementsOutputUseCase, StringErrorOutput> {

        let basicPersonData = try managersProvider.getBsanPersonDataManager().loadBasicPersonData()
        if basicPersonData.isSuccess() {
           personBasicInfo = try basicPersonData.getResponseData()
        }
        
        // extract IBAN of accounts wich are: visibles AND the current user is the Holder (titularRetail or titularPB)
        visibleAccountsAndHolder = merger.accounts.visibles()
            .filter({$0.isAccountHolder()})
            .compactMap({$0.dto.iban?.description})
        
        guard let direction = TimeLineDirection(rawValue: requestValues.direction.rawValue) else {
            return .error(StringErrorOutput(nil))
        }
        let params = TimeLineMovementsParameters(date: requestValues.date, offset: requestValues.offset, limit: requestValues.limit, direction: direction)
        let response = try timeLineManager.getMovements(params)
        
        if response.isSuccess(), let respDto = try response.getResponseData() {
            self.timelineMovements.append(contentsOf: respDto.data.movements)
            while let nextPage = respDto.pagination.next {
                let params = TimeLineMovementsInputUseCase(date: requestValues.date, offset: nextPage, limit: requestValues.limit, direction: requestValues.direction)
                return try self.executeUseCase(requestValues: params)
            }
            let parseResult = parseOkresponseWithMovements(self.timelineMovements)
            return .ok(TimeLineMovementsOutputUseCase(timeLineResult: parseResult))
        }
        return .error(StringErrorOutput( try response.getErrorMessage()))
    }
}

private extension TimeLineMovementsUseCase {
    /// Check if the specified dto is contained in the types specified in the type parameter, also check if visible accounts contains the iban present in the dto item
    /// - Parameters:
    ///   - type: type of transactions
    ///   - dto: dto entity
    func movementQualifyFor(_ types: [TimeLineTransactionTypeDTO], withDto dto: TimeLineMovementDTO) -> Bool {
        return
            dto.existInVisibleIBANs(self.visibleAccountsAndHolder) &&
            dto.existInTypes(types) &&
            dto.consolidated
    }
    
    func parseOkresponseWithMovements(_ movements: [TimeLineMovementDTO]) -> TimeLineResultEntity {
        var reducedDebtArray: [TimeLineDebtEntity] = [TimeLineDebtEntity]()
        var receiptsArray: [TimeLineReceiptEntity] = [TimeLineReceiptEntity]()
        var transfersInArray: [TimeLineTransfersEntity] = [TimeLineTransfersEntity]()
        var transfersOutArray: [TimeLineTransfersEntity] = [TimeLineTransfersEntity]()
        var scheduledTransferArray: [TimeLineTransfersEntity] = [TimeLineTransfersEntity]()
        var subscriptionsArray: [TimeLineSubscriptionEntity] = [TimeLineSubscriptionEntity]()
        var bizumInArray: [TimeLineBizumEntity] = [TimeLineBizumEntity]()
        var bizumOutArray: [TimeLineBizumEntity] = [TimeLineBizumEntity]()

        movements.forEach { (movementDto)  in
            // DEUDA REDUCIDA: HIPOTECA+PRESTAMOS
            if movementQualifyFor([.loan, .mortage, .cardClearing], withDto: movementDto) {
                let entity = TimeLineDebtEntity(fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, amount: movementDto.amount.value, ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")), description: movementDto.transaction
                    .description)
                reducedDebtArray.append(entity)
            }
            
            // RECIBOS: listado de recibos
            if movementQualifyFor([.receipt], withDto: movementDto) {
                let entity =  TimeLineReceiptEntity(amount: movementDto.amount.value, merchant: (code: movementDto.merchant.code, name: movementDto.merchant.name), fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")))
                   receiptsArray.append(entity)
            }
            
            // TRANSFERENCIAS RECIBIDAS:
            if movementQualifyFor([.trPunctualReceived], withDto: movementDto) {
                let entity = TimeLineTransfersEntity(amount: movementDto.amount.value, fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, merchant: (code: movementDto.merchant.code, name: movementDto.merchant.name), ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")), transferType: .received)
                transfersInArray.append(entity)
            }
            
            // TRANSFERENCIAS EMITIDAS:
            if movementQualifyFor([.trPunctualEmitted], withDto: movementDto) {
                let entity = TimeLineTransfersEntity(amount: movementDto.amount.value, fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, merchant: (code: movementDto.merchant.code, name: movementDto.merchant.name), ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")), transferType: .emitted)
                transfersOutArray.append(entity)
            }
            
            // TRANSFERENCIAS PROGRAMADAS:
            if movementQualifyFor([.trScheduled], withDto: movementDto) {
                let entity = TimeLineTransfersEntity(amount: movementDto.amount.value, fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, merchant: (code: movementDto.merchant.code, name: movementDto.merchant.name), ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")), transferType: movementDto.amount.value < 0 ? .emitted : .received)
                scheduledTransferArray.append(entity)
            }
            
            // SUSCRIPCIONES:
            if movementQualifyFor([.cardSubscription], withDto: movementDto) {
                let entity = TimeLineSubscriptionEntity(amount: movementDto.amount.value, merchant: (code: movementDto.merchant.code, name: movementDto.merchant.name), ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")), fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, name: movementDto.merchant
                    .name)
                subscriptionsArray.append(entity)
            }
            
            // BIZUM RECIBIDOS:
            if movementQualifyFor([.bizumReceived], withDto: movementDto) {
                let entity = TimeLineBizumEntity(amount: movementDto.amount.value, fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, merchant: (code: movementDto.merchant.code, name: movementDto.merchant.name), ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")), transferType: .received)
                bizumInArray.append(entity)
            }
            
            // BIZUM EMITIDOS:
            if movementQualifyFor([.bizumEmitted], withDto: movementDto) {
                let entity = TimeLineBizumEntity(amount: movementDto.amount.value, fullDate: movementDto.transaction.date.date, month: movementDto.transaction.date.month, merchant: (code: movementDto.merchant.code, name: movementDto.merchant.name), ibanEntity: IBANEntity(IBANDTO(ibanString: movementDto.iban ?? "")), transferType: .emitted)
                bizumOutArray.append(entity)
            }
        }
        var result = TimeLineResultEntity()
        result.reducedDebt = reducedDebtArray
        result.transfersIn = transfersInArray
        result.transfersOut = transfersOutArray
        result.transfersScheduled = scheduledTransferArray
        result.bizumsIn = bizumInArray
        result.bizumsOut = bizumOutArray
        result.subscriptions = subscriptionsArray
        result.receipts = receiptsArray
        result.bizumPhoneNumber = personBasicInfo?.phoneNumber
        return result
    }
}

struct TimeLineMovementsInputUseCase {
     /// date of start the search
    public var date: Date
     /// used for pagination, it would be the id of the first movement of the page
    public var offset: String
     /// results per page, default 15
    public var limit: Int? = 15
     /// search direction taking date as reference, forward means date to future, bakward means past
    public var direction: TimelineSearchDirection
}

struct TimeLineMovementsOutputUseCase {
    let timeLineResult: TimeLineResultEntity
}

// Contains logic related to TimeLineMovementDTO before return results. Parse here as much as possible to speedup calcs later on viewmodel
private extension TimeLineMovementDTO {
    /**
     Consolidated movements is a movements already charged on the account. Its based on periodicity wich could be "0" or "1" the earlier means consolidated the later means a movement wich could be charged on the future
     */
    var consolidated: Bool {
        self.periodicity == "0"
    }
    /**
     Check that instance iban is withing specified array of visible ibans.
     
     - Returns: true if is within visible ibans.
     
     - Important: Can return false if iban is nil.
     */
    func existInVisibleIBANs(_ visibleIBANs: [String]) -> Bool {
        guard let iban = self.iban else { return false }
        return visibleIBANs.contains(iban)
    }
    /**
     Check that instance is whithin passed types of transactions.
     
     - Returns: true if the instance type is at least one of the passed elements..
     */
    func existInTypes(_ types: [TimeLineTransactionTypeDTO]) -> Bool {
        return types.contains(self.transaction.type)
    }
}
