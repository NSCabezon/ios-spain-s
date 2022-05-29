import CoreFoundationLib
import SANLegacyLibrary
import Transfer
import TransferOperatives
import CoreDomain

enum SubtypeTransferUseCaseError: Error {
    case notImplemented
}

class SubtypeTransferUseCase<Input: SubtypeTransferUseCaseInput, Output, ResponseOutput: ValidateTransferProtocol>: UseCase<Input, Output, SubtypeTransferUseCaseErrorOutput> {
    let provider: BSANManagersProvider
    let dependenciesResolver: DependenciesResolver?
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let errorPL_5304 = "PL_5304"
    private let errorSI_1016 = "SI_1016"
    private let errorSI_1018 = "SI_1018"
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Input) throws -> UseCaseResponse<Output, SubtypeTransferUseCaseErrorOutput> {
        switch requestValues.type {
        case .national:
            return try sepaTransfer(national: true, requestValues: requestValues)
        case .sepa:
            return try sepaTransfer(national: false, requestValues: requestValues)
        case .noSepa:
            return try noSepaTransfer(requestValues: requestValues)
        }
    }
    
    private func checkError5304 (response: BSANResponse<ResponseOutput>) -> Bool {
        if appConfigRepository.getBool(DomainConstant.appConfigIsEnabledUrgentNationalTransfersError5304) == true {
            if let errorDesc = try? response.getErrorMessage(), errorDesc == errorPL_5304 {
                return true
            }
            if let data = try? response.getResponseData(), data.errorCode == errorPL_5304 {
                return true
            }
        }
        return false
    }
    
    func executeValidateTransfer(requestValues: Input, inputDTO: GenericTransferInputDTO) throws -> BSANResponse<ResponseOutput> {
        throw SubtypeTransferUseCaseError.notImplemented
    }
    
    func proccessResponse(output: ResponseOutput) throws -> UseCaseResponse<Output, SubtypeTransferUseCaseErrorOutput> {
        return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
    }
    
    private func allowInmediateTransfer() -> Bool {
        return self.dependenciesResolver?.resolve(forOptionalType: OnePayTransferModifierProtocol.self) == nil
    }
    
    private func sepaTransfer(national: Bool, requestValues: Input) throws -> UseCaseResponse<Output, SubtypeTransferUseCaseErrorOutput> {
        let transferManger = provider.getBsanTransfersManager()
        let transferTypeDTO: TransferTypeDTO
        if national {
            switch requestValues.subtype {
            case .urgent:
                transferTypeDTO = .NATIONAL_URGENT_TRANSFER
            case .immediate:
                transferTypeDTO = .NATIONAL_INSTANT_TRANSFER
            case .standard:
                transferTypeDTO = .NATIONAL_TRANSFER
            }
        } else {
            transferTypeDTO = .INTERNATIONAL_SEPA_TRANSFER
        }
        let input = GenericTransferInputDTO(
            beneficiary: requestValues.beneficiary,
            isSpanishResident: requestValues.isSpanishResident,
            ibandto: requestValues.iban.ibanDTO,
            saveAsUsual: requestValues.saveAsUsual,
            saveAsUsualAlias: requestValues.alias,
            beneficiaryMail: requestValues.beneficiaryMail,
            amountDTO: requestValues.amount.amountDTO,
            concept: requestValues.concept,
            transferType: transferTypeDTO,
            tokenPush: requestValues.tokenPush
        )
        
        if requestValues.subtype == .immediate, self.allowInmediateTransfer() {
            guard requestValues.maxAmount == nil || requestValues.amount.value ?? -1 < requestValues.maxAmount?.value ?? 0 else {
                return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.maxAmount))
            }
            let responseAdhered = try transferManger.checkEntityAdhered(genericTransferInput: input)
            guard responseAdhered.isSuccess() else {
                let errorDesc = try responseAdhered.getErrorMessage()
                if errorDesc == errorSI_1016 || errorDesc == errorSI_1018 {
                    return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.nonAttachedEntity))
                } else {
                    return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDesc)))
                }
            }
        }
        do {
            let response = try executeValidateTransfer(requestValues: requestValues, inputDTO: input)
            guard requestValues.subtype != .urgent || !checkError5304(response: response) else {
                let textError5304: String? = appConfigRepository.getString(DomainConstant.appConfigUrgentNationalTransfersError5304Text)
                return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.urgentNationalTransfers5304(text: textError5304)))
            }
            guard response.isSuccess(), let data = try response.getResponseData() else {
                let errorDesc = try response.getErrorMessage()
                return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDesc)))
            }
            return try proccessResponse(output: data)
        } catch CoreExceptions.network {
            return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.noConnection))
        } catch let error {
            return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
        
    }
    
    private func noSepaTransfer(requestValues: Input) throws -> UseCaseResponse<Output, SubtypeTransferUseCaseErrorOutput> {
        //TODO: Transferencias no sepa
        return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
    }
}

enum SubtypeTransferError {
    case maxAmount
    case urgentNationalTransfers5304(text: String?)
    case nonAttachedEntity
    case serviceError(errorDesc: String?)
    case noConnection
}

protocol SubtypeTransferUseCaseInput {
    var type: OnePayTransferType { get }
    var subtype: OnePayTransferSubType { get }
    var beneficiary: String? { get }
    var beneficiaryMail: String? { get }
    var isSpanishResident: Bool { get }
    var iban: IBAN { get }
    var saveAsUsual: Bool { get }
    var alias: String? { get }
    var amount: Amount { get }
    var maxAmount: Amount? { get }
    var concept: String? { get }
    var tokenPush: String? { get }
}

protocol ValidateTransferProtocol {
    var errorCode: String? { get }
}

class SubtypeTransferUseCaseErrorOutput: StringErrorOutput {
    let error: SubtypeTransferError
    
    init(_ error: SubtypeTransferError) {
        self.error = error
        super.init("")
    }
}
