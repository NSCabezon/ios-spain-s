import SANLegacyLibrary
import CoreFoundationLib

class ConfirmOnePayTransferUseCase: ConfirmUseCase<ConfirmOnePayTransferUseCaseInput, ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository,
         trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let type = TransferStrategyType.transferType(type: requestValues.type, time: requestValues.time)
        let strategy = type.strategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        return try strategy.confirmTransfer(requestValues: requestValues)
    }
}

struct ConfirmOnePayTransferUseCaseInput {
    let signature: Signature?
    let type: OnePayTransferType
    let originAccount: Account
    let amount: Amount
    let beneficiary: String
    let isSpanishResident: Bool
    let iban: IBAN
    let saveAsUsual: Bool
    let concept: String?
    let saveAsUsualAlias: String?
    let beneficiaryMail: String?
    let time: OnePayTransferTime
    let dataMagicPhrase: String?
    var tokenSteps: String?
    var footPrint: String?
    var deviceToken: String?
    
    init(signature: Signature?,
         type: OnePayTransferType,
         originAccount: Account,
         amount: Amount,
         beneficiary: String,
         isSpanishResident: Bool,
         iban: IBAN,
         saveAsUsual: Bool,
         concept: String?,
         saveAsUsualAlias: String?,
         beneficiaryMail: String?,
         time: OnePayTransferTime,
         dataMagicPhrase: String?,
         tokenSteps: String? = nil,
         footPrint: String? = nil ,
         deviceToken: String? = nil) {
        self.signature = signature
        self.type = type
        self.originAccount = originAccount
        self.amount = amount
        self.beneficiary = beneficiary
        self.isSpanishResident = isSpanishResident
        self.iban = iban
        self.saveAsUsual = saveAsUsual
        self.concept = concept
        self.saveAsUsualAlias = saveAsUsualAlias
        self.beneficiaryMail = beneficiaryMail
        self.time = time
        self.dataMagicPhrase = dataMagicPhrase
        self.tokenSteps = tokenSteps
        self.footPrint = footPrint
        self.deviceToken = deviceToken
    }
}

struct ConfirmOnePayTransferUseCaseOkOutput {
    let otp: OTP
    let sanKeyOTP: SanKeyOTPValidationDTO?
    
    public init(otp: OTP,
                sanKeyOTP: SanKeyOTPValidationDTO? = nil) {
        self.otp = otp
        self.sanKeyOTP = sanKeyOTP
    }
}
