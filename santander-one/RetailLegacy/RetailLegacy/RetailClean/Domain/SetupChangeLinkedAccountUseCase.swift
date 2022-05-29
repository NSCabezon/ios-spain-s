import CoreFoundationLib
import SANLegacyLibrary


class SetupChangeLinkedAccountUseCase: SetupUseCase<SetupChangeLinkedAccountUseCaseInput, SetupChangeLinkedAccountUseCaseOkOutput, SetupChangeLinkedAccountUseCaseErrorOutput> {
    let appRepository: AppRepository
    let provider: BSANManagersProvider
    let accountDescriptorRepository: AccountDescriptorRepository
    
    init(appRepository: AppRepository, appConfig: AppConfigRepository, accountDescriptorRepository: AccountDescriptorRepository, bsanManagerProvider: BSANManagersProvider) {
        self.provider = bsanManagerProvider
        self.appRepository = appRepository
        self.accountDescriptorRepository = accountDescriptorRepository
        super.init(appConfigRepository: appConfig)
    }
    
    override func executeUseCase(requestValues: SetupChangeLinkedAccountUseCaseInput) throws -> UseCaseResponse<SetupChangeLinkedAccountUseCaseOkOutput, SetupChangeLinkedAccountUseCaseErrorOutput> {
       
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig

        let selectedLoan = requestValues.loan
        let detailResponse = try provider.getBsanLoansManager().getLoanDetail(forLoan: selectedLoan.loanDTO)
        
        guard detailResponse.isSuccess(), let loanDetail = try detailResponse.getResponseData() else {
            return UseCaseResponse.error(SetupChangeLinkedAccountUseCaseErrorOutput(try detailResponse.getErrorMessage()))
        }
        
        guard let gpWrapper = try getGPWrapper(appRepository, provider, accountDescriptorRepository, appConfigRepository) else {
            return UseCaseResponse.error(SetupChangeLinkedAccountUseCaseErrorOutput(nil))
        }
        
        _ = try? provider.getBsanPGManager().loadGlobalPositionV2(onlyVisibleProducts: true, isPB: gpWrapper.isPb)
        let loanDetailDO = LoanDetail.create(selectedLoan.loanDTO, detailDTO: loanDetail)
        
        let accountList = gpWrapper.accounts.getVisibles()
        let valids = accountList.filter { loanDetail.linkedAccountContract != $0.accountDTO.oldContract }

        return UseCaseResponse.ok(SetupChangeLinkedAccountUseCaseOkOutput(allowChangeAccount: !valids.isEmpty, loanDetail: loanDetailDO, validList: AccountList(valids), operativeConfig: operativeConfig))
    }
}

extension SetupChangeLinkedAccountUseCase: GettingGPWrapperCapable {}

struct SetupChangeLinkedAccountUseCaseInput {
    let loan: Loan
}

struct SetupChangeLinkedAccountUseCaseOkOutput {
    let allowChangeAccount: Bool
    let loanDetail: LoanDetail
    let validList: AccountList
    var operativeConfig: OperativeConfig
}

extension SetupChangeLinkedAccountUseCaseOkOutput: SetupUseCaseOkOutputProtocol {}

class SetupChangeLinkedAccountUseCaseErrorOutput: StringErrorOutput {}
