import CoreFoundationLib
import CoreTestData
import Localization
import QuickSetup
import CoreDomain

public final class TransferOperativesDependenciesInitializer: ModuleDependenciesInitializer {
    private let mockDataInjector: MockDataInjector
    private let dependencies: DependenciesInjector
    private let colorByNamesEngine: ColorsByNameEngine
    
    public init(dependencies: DependenciesInjector) {
        self.dependencies = dependencies
        self.colorByNamesEngine = ColorsByNameEngine()
        self.mockDataInjector = MockDataInjector()
    }
    
    public init(dependencies: DependenciesInjector, injector: MockDataInjector) {
        self.dependencies = dependencies
        self.colorByNamesEngine = ColorsByNameEngine()
        self.mockDataInjector = injector
    }
    
    public func registerDependencies() {
        self.dependencies.register(for: ContactsEngineProtocol.self) { _ in
            return MockContactsEngine(mockDataInjector: self.mockDataInjector)
        }
        self.dependencies.register(for: ColorsByNameEngine.self) { _ in
            return self.colorByNamesEngine
        }
        self.dependencies.register(for: IbanValidationSendMoneyUseCaseProtocol.self) { _ in
            return MockIbanValidationSendMoneyUseCase()
        }
    }
}

public final class TransferOperativesServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
        injector.register(
            for: \.sepaInfo.getSepaList,
            filename: "getSepaList"
        )
        injector.register(
            for: \.transferData.validateUpdateSepaPayee,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.transferData.sepaPayeeDetail,
            filename: "SepaPayeeDetailDTOMock"
        )
        injector.register(
            for: \.transferData.validateCreateSepaPayee,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.transferData.validateCreateSepaPayeeOTP,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.validateRemoveSepaPayee,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.transferData.confirmRemoveSepaPayee,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.transferData.validateUpdateSepaPayeeOTP,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.getUsualTransfers,
            filename: "TransfersDTOMock"
        )
        injector.register(
            for: \.transferData.confirmUsualTransfer,
            filename: "TransferConfirmAccountDTOMock"
        )
        injector.register(
            for: \.transferData.getScheduledTransfers,
            filename: "TransferScheduledListDTODictMock"
        )
        injector.register(
            for: \.transferData.loadScheduledTransfers,
            filename: "TransferScheduledListDTOMock"
        )
        injector.register(
            for: \.transferData.getScheduledTransferDetail,
            filename: "TransferScheduledDetailDTOMock"
        )
        injector.register(
            for: \.transferData.validateScheduledTransferOTP,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.modifyPeriodicTransferDetail,
            filename: "ModifyPeriodicTransferDTOMock"
        )
        injector.register(
            for: \.transferData.validateModifyPeriodicTransfer,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.validateScheduledTransferOTP,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.modifyDeferredTransferDetail,
            filename: "ModifyDeferredTransferDTOMock"
        )
        injector.register(
            for: \.transferData.validateModifyDeferredTransfer,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.getEmittedTransfers,
            filename: "TransferEmittedListDTODictMock"
        )
        injector.register(
            for: \.transferData.loadEmittedTransfers,
            filename: "TransferEmittedListDTOMock"
        )
        injector.register(
            for: \.transferData.getEmittedTransferDetail,
            filename: "TransferEmittedDetailDTOMock"
        )
        injector.register(
            for: \.transferData.getAccountTransactions,
            filename: "AccountTransactionsListDTOMock"
        )
        injector.register(
            for: \.transferData.transferType,
            filename: "TransfersTypeMock"
        )
        injector.register(
            for: \.transferData.validateSwift,
            filename: "ValidationSwiftDTOMock"
        )
        injector.register(
            for: \.transferData.validationIntNoSEPA,
            filename: "ValidationIntNoSepaDTOMock"
        )
        injector.register(
            for: \.transferData.validationOTPIntNoSEPA,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.confirmationIntNoSEPA,
            filename: "ConfirmationNoSEPADTOMock"
        )
        injector.register(
            for: \.transferData.loadEmittedNoSepaTransferDetail,
            filename: "NoSepaTransferEmittedDetailDTOMock"
        )
        injector.register(
            for: \.transferData.validateGenericTransferOTP,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.confirmGenericTransfer,
            filename: "TransferConfirmAccountDTOMock"
        )
        injector.register(
            for: \.transferData.checkTransferStatus,
            filename: "CheckTransferStatusDTOMock"
        )
        injector.register(
            for: \.transferData.loadAllUsualTransfers,
            filename: "TransfersDTOMock"
        )
        injector.register(
            for: \.transferData.noSepaPayeeDetail,
            filename: "NoSepaPayeeDetailDTOMock"
        )
        injector.register(
            for: \.transferData.validateCreateNoSepaPayee,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.transferData.validateCreateNoSepaPayeeOTP,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.confirmCreateNoSepaPayee,
            filename: "ConfirmCreateNoSepaPayeeDTOMock"
        )
        injector.register(
            for: \.transferData.validateUpdateNoSepaPayee,
            filename: "mockSignatureWithTokenDTO"
        )
        injector.register(
            for: \.transferData.validateUpdateNoSepaPayeeOTP,
            filename: "OTPValidationDTOMock"
        )
        injector.register(
            for: \.transferData.loadTransferSubTypeCommissions,
            filename: "TransferSubTypeCommissionDTOMock"
        )
        injector.register(
            for: \.transferData.fetchContacts,
            filename: "ContactEntityListMock"
        )
        injector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            filename: "app_config_v2"
        )
    }
}

public struct MockContactsEngine: ContactsEngineProtocol {
    
    let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func fetchContacts(_ completion: @escaping (Result<[PayeeRepresentable], ContactsEngineError>) -> Void) {
        let data = self.mockDataInjector.mockDataProvider.transferData.fetchContacts
        completion(.success(data ?? []))
    }
}

public final class MockIbanValidationSendMoneyUseCase: UseCase<IbanValidationSendMoneyUseCaseInput, IbanValidationSendMoneyUseCaseOkOutput, DestinationAccountSendMoneyUseCaseErrorOutput> {
    public override func executeUseCase(requestValues: IbanValidationSendMoneyUseCaseInput) throws -> UseCaseResponse<IbanValidationSendMoneyUseCaseOkOutput, DestinationAccountSendMoneyUseCaseErrorOutput> {
        return .ok(.empty)
    }
}

extension MockIbanValidationSendMoneyUseCase: IbanValidationSendMoneyUseCaseProtocol { }
