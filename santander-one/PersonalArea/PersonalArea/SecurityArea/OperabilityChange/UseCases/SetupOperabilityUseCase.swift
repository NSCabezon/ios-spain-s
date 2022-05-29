//
//  SetupOperabilityUseCase.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 19/05/2020.
//

import CoreFoundationLib
import SANLegacyLibrary

final class SetupOperabilityUseCase: UseCase<Void, SetupOperabilityUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupOperabilityUseCaseOkOutput, StringErrorOutput> {
        let provider: BSANManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let response = try provider.getBsanSignatureManager().getCMCSignature()
        let data = response.isSuccess() ? try response.getResponseData() : nil
        let operabilityInd = getOperabilityInd(signatureStatusInfo: data)
        return .ok(SetupOperabilityUseCaseOkOutput(operabilityInd: operabilityInd, isUnderage: isUnderage(signatureStatusInfo: data) && operabilityInd == .consultive, isSignatureBlocked: isSignatureBlocked(signatureStatusInfo: data), isUserWithoutCMC: isUserWithoutCMC(signatureStatusInfo: data)))
    }
    
    private func getOperabilityInd(signatureStatusInfo: SignStatusInfo?) -> OperabilityInd {
        guard let info = signatureStatusInfo else {
            return .operative
        }
        return info.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() == "C" ? .consultive : .operative
    }
}

private extension SetupOperabilityUseCase {
    func isUnderage(signatureStatusInfo: SignStatusInfo?) -> Bool {
        return containsAdvisoryUserInd("9", signatureStatusInfo: signatureStatusInfo)
    }
    
    func isSignatureBlocked(signatureStatusInfo: SignStatusInfo?) -> Bool {
        let operabilityInd = signatureStatusInfo?.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() ?? ""
        let signatureActivityStatusInd = signatureStatusInfo?.signatureDataDTO.signatureActivityStatusInd?.uppercased() ?? ""
        let signaturePhaseStatusInd = signatureStatusInfo?.signatureDataDTO.signaturePhaseStatusInd?.uppercased() ?? ""

        let caseI4 = signatureActivityStatusInd == "I" && signaturePhaseStatusInd == "4"
        let caseI6 = signatureActivityStatusInd == "I" && signaturePhaseStatusInd == "6"
        let caseI1C5 = signatureActivityStatusInd == "I" && signaturePhaseStatusInd == "1" && operabilityInd == "C" && containsAdvisoryUserInd("5", signatureStatusInfo: signatureStatusInfo)
        let caseC4 = operabilityInd == "C" && containsAdvisoryUserInd("4", signatureStatusInfo: signatureStatusInfo)
        
        return caseI4 || caseI6 || caseI1C5 || caseC4
    }
    
    func containsAdvisoryUserInd(_ advisoryUserInd: String, signatureStatusInfo: SignStatusInfo?) -> Bool {
        guard let list = signatureStatusInfo?.signatureDataDTO.list else { return false }
        return list.contains(where: { $0.advisoryUserInd == advisoryUserInd }) 
    }
    
    func isUserWithoutCMC(signatureStatusInfo: SignStatusInfo?) -> Bool {
        let operabilityInd = signatureStatusInfo?.signatureDataDTO.list?.first?.userOperabilityInd?.uppercased() ?? ""
        let caseC1 = operabilityInd == "C" && containsAdvisoryUserInd("1", signatureStatusInfo: signatureStatusInfo)
        let signatureActivityStatus = signatureStatusInfo?.signatureDataDTO.signatureActivityStatusInd == nil
        let signaturePhaseStatus = signatureStatusInfo?.signatureDataDTO.signaturePhaseStatusInd == nil
        return caseC1 && signatureActivityStatus && signaturePhaseStatus
    }
}

struct SetupOperabilityUseCaseOkOutput {
    let operabilityInd: OperabilityInd
    let isUnderage: Bool
    let isSignatureBlocked: Bool
    let isUserWithoutCMC: Bool
}
