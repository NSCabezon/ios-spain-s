//
//  SendMoneyDependencies.swift
//  Santander
//
//  Created by David Gálvez Alonso on 3/2/22.
//

import CoreFoundationLib
import TransferOperatives

struct SendMoneyDependencies {
    let dependenciesEngine: DependenciesResolver & DependenciesInjector

    func registerDependencies() {
        self.dependenciesEngine.register(for: GetAllTypesOfTransfersUseCaseProtocol.self) { resolver in
            return SpainGetAllTypesOfTransfersUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SendMoneyDestinationUseCaseProtocol.self) { resolver in
            return SPSendMoneyDestinationUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SendMoneyAmountUseCaseProtocol.self) { resolver in
            return SPSendMoneyAmountUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SendMoneyAmountNoSepaUseCaseProtocol.self) { resolver in
            return SPSendMoneyAmountNoSepaUseCase(dependeciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SendMoneyGetFeesUseCaseProtocol.self) { resolver in
            return SPSendMoneyGetFeesUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SendMoneyConfirmationUseCaseProtocol.self) { resolver in
            return SPSendMoneyConfirmationUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: SendMoneyConfirmationNoSepaUseCaseProtocol.self) { resolver in
            return SPSendMoneyConfirmationNoSepaUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ValidateOTPNoSepaUseCaseProtocol.self) { resolver in
            return SPValidateOTPNoSepaUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesEngine.register(for: ConfirmSendMoneyNoSepaUseCaseProtocol.self) { resolver in
            return SPConfirmSendMoneyNoSepaUseCase(dependenciesResolver: resolver)
        }
    }
}
