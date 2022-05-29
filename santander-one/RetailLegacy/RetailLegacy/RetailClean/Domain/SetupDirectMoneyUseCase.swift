import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class SetupDirectMoneyUseCase: SetupUseCase<SetupDirectMoneyUseCaseInput, SetupDirectMoneyUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    private var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.dependenciesResolver = dependenciesResolver
        super.init(appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: SetupDirectMoneyUseCaseInput) throws -> UseCaseResponse<SetupDirectMoneyUseCaseOkOutput, StringErrorOutput> {
        guard let card = requestValues.card else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        let operativeConfig = try getOperativeConfig().getOkResult().operativeConfig
        let cardDto = card.cardDTO
        let cardManager = provider.getBsanCardsManager()
        let responseDetailCard = try cardManager.getCardDetail(cardDTO: cardDto)
        guard responseDetailCard.isSuccess(), let dataDetailCard = try responseDetailCard.getResponseData() else {
            let error = try responseDetailCard.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let clientName = try? checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())?.clientName ?? ""
        let cardData: CardDataDTO?
        if let pan = cardDto.formattedPAN, let responseCardData = try? cardManager.getCardData(pan), responseCardData.isSuccess(), let cardDataResponse = try? responseCardData.getResponseData() {
            cardData = cardDataResponse
        } else {
            cardData = nil
        }
        let cardDetail = CardDetail.create(dataDetailCard, cardDataDTO: cardData, clientName: clientName ?? "")
        let response = try cardManager.prepareDirectMoney(cardDTO: cardDto)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let directMoney = DirectMoney(dto: data)
        let linkedAccountBank = data.linkedAccountBank ?? ""
        let linkedAccountBranch = data.linkedAccountBranch ?? ""
        let linkedAccountCheckDigits = data.linkedAccountCheckDigits ?? ""
        let linkedAccountNumber = data.linkedAccountNumber ?? ""
        let linkedAccountContract = ContractDTO(bankCode: linkedAccountBank, branchCode: linkedAccountBranch, product: linkedAccountCheckDigits, contractNumber: linkedAccountNumber)
        let account: Account?
        if let accountDTOUnwrapped = try? checkRepositoryResponse(provider.getBsanAccountsManager().getAccount(fromOldContract: linkedAccountContract)) ?? nil {
            account = Account(dto: accountDTOUnwrapped)
        } else {
            account = nil
        }
        let iban: IBAN
        if let accountIban =  account?.getIban() {
            iban = accountIban
        } else {
            let bbanString = linkedAccountBank + linkedAccountBranch + linkedAccountCheckDigits + linkedAccountNumber
            let dcIban = bankingUtils.calculateCheckDigit(bban: bbanString, countryCode: "ES")
            guard !dcIban.isEmpty else {
                let error = try response.getErrorMessage()
                return UseCaseResponse.error(StringErrorOutput(error))
            }
            let ibanString = "ES" + dcIban + linkedAccountBank + linkedAccountBranch + linkedAccountCheckDigits + linkedAccountNumber
            let ibanDto = IBANDTO(ibanString: ibanString)
            iban = IBAN(dto: ibanDto)
        }
        let okResponse = SetupDirectMoneyUseCaseOkOutput(directMoney: directMoney, cardDetail: cardDetail, account: account, iban: iban, operativeConfig: operativeConfig)
        return UseCaseResponse.ok(okResponse)
    }
}

struct SetupDirectMoneyUseCaseInput {
    let card: Card?
}

struct SetupDirectMoneyUseCaseOkOutput {
    let directMoney: DirectMoney
    let cardDetail: CardDetail
    let account: Account?
    let iban: IBAN
    var operativeConfig: OperativeConfig
}

extension SetupDirectMoneyUseCaseOkOutput: SetupUseCaseOkOutputProtocol {
}
