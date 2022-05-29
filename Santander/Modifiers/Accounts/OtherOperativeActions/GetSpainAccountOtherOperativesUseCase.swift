import SANLegacyLibrary
import CoreFoundationLib
import Account

final class GetSpainAccountOtherOperativesActionUseCase: UseCase<GetAccountOtherOperativesActionUseCaseInput, GetAccountOtherOperativesActionUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    private let requestBizum: AccountActionType = .custome(
        identifier: "bizum",
        accesibilityIdentifier: "accountsHomeBtnRequestBizum",
        trackName: "bizum",
        localizedKey: "accountOption_button_askBizum",
        icon: "icnRequestMoney"
    )
    
    private let donationBizum: AccountActionType = .custome(
        identifier: "bizum",
        accesibilityIdentifier: "accountsHomeBtnDonationBizum",
        trackName: "bizum",
        localizedKey: "cardsOption_button_contractCards",
        icon: "icnContract"
    )
    
    private lazy var everyDayOperatives: [AccountActionType] = {
        [.internalTransfer, .favoriteTransfer, .fxPay(nil),
         .payTax, .returnBill, .changeDomicileReceipt,
         .cancelBill, requestBizum, donationBizum,
         .donation(nil), .correosCash(nil), .receiptFinancing(nil), .automaticOperations(nil)]
    }()
    
    private lazy var otherOperativeActions: [AccountActionType] = {
        [.internalTransfer, .favoriteTransfer, .fxPay(nil),
        .payTax, .returnBill, .changeDomicileReceipt,
        .cancelBill, .accountDetail, requestBizum,
        .donation(nil), .historicalEmitted, .one(nil),
        .contractAccount(nil), .ownershipCertificate(nil),
        .foreignExchange(nil), .correosCash(nil), .receiptFinancing(nil), .automaticOperations(nil)]
    }()
    
    private let queriesActions: [AccountActionType] = {
        [.accountDetail, .historicalEmitted]
    }()
    
    private let contractActions: [AccountActionType] = {
        [.one(nil), .contractAccount(nil)]
    }()
    
    private let officeArrengamentActions: [AccountActionType] = {
        [.ownershipCertificate(nil), .foreignExchange(nil)]
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountOtherOperativesActionUseCaseInput) throws -> UseCaseResponse<GetAccountOtherOperativesActionUseCaseOkOutput, StringErrorOutput> {
        return .ok(GetAccountOtherOperativesActionUseCaseOkOutput(everyDayOperatives: everyDayOperatives, otherOperativeActions: otherOperativeActions, adjustAccounts: [], queriesActions: queriesActions, contractActions: contractActions, officeArrangementActions: officeArrengamentActions))
    }
}

extension GetSpainAccountOtherOperativesActionUseCase: GetAccountOtherOperativesActionUseCaseProtocol {}
