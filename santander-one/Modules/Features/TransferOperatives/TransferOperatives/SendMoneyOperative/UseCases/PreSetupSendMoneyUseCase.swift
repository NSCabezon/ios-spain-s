//
//  PreSetupSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol PreSetupSendMoneyUseCaseProtocol: UseCase<Void, PreSetupSendMoneyUseCaseOkOutput, StringErrorOutput> { }

class PreSetupSendMoneyUseCase: UseCase<Void, PreSetupSendMoneyUseCaseOkOutput, StringErrorOutput> {

    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<PreSetupSendMoneyUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let accountsVisibles: [AccountRepresentable] = globalPosition.accountsVisiblesWithoutPiggy.map { $0.dto }
        let accountsNotVisibles: [AccountRepresentable] = globalPosition.accountsNotVisiblesWithoutPiggy.map { $0.dto }
        let faqsRepository: FaqsRepositoryProtocol = self.dependenciesResolver.resolve()
        let faqs: [FaqRepresentable]? = faqsRepository.getFaqsList()?.transferOperative
        guard let sepaList = getSepaInfo(),
              accountsVisibles.count > 0,
              sepaList.allCurrenciesRepresentable.count > 0 else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        return .ok(PreSetupSendMoneyUseCaseOkOutput(
                    accountVisibles: accountsVisibles,
                    accountNotVisibles: accountsNotVisibles,
                    sepaList: sepaList,
                    faqs: faqs))
    }
}

extension PreSetupSendMoneyUseCase: PreSetupSendMoneyUseCaseProtocol { }

private extension PreSetupSendMoneyUseCase {
    func getSepaInfo() -> SepaInfoListRepresentable? {
        let sepaInfoRepository = self.dependenciesResolver.resolve(for: SepaInfoRepositoryProtocol.self)
        return sepaInfoRepository.getSepaList()
    }
}

public struct PreSetupSendMoneyUseCaseOkOutput {
    let accountVisibles: [AccountRepresentable]
    let accountNotVisibles: [AccountRepresentable]
    let sepaList: SepaInfoListRepresentable
    let faqs: [FaqRepresentable]?
    
    public init(accountVisibles: [AccountRepresentable],
                accountNotVisibles: [AccountRepresentable],
                sepaList: SepaInfoListRepresentable,
                faqs: [FaqRepresentable]?) {
        self.accountVisibles = accountVisibles
        self.accountNotVisibles = accountNotVisibles
        self.sepaList = sepaList
        self.faqs = faqs
    }
}
