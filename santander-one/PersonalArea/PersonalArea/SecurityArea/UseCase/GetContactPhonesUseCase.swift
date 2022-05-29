//
//  GetContactUseCase.swift
//  Account
//
//  Created by Juan Carlos López Robles on 3/3/20.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public protocol GetContactPhonesUseCaseProtocol: UseCase<Void, GetContactPhonesUseCaseOutput, StringErrorOutput> { }

final class GetContactPhonesUseCase: UseCase<Void, GetContactPhonesUseCaseOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetContactPhonesUseCaseOutput, StringErrorOutput> {
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        guard let commercialSegment = try checkRepositoryResponse(appRepository.getCommercialSegment()) ?? nil else {
            return .error(StringErrorOutput(nil))
        }
        guard let fraude = commercialSegment.contact?.fraudFeedback else {
            return .error(StringErrorOutput(nil))
        }
        guard let cardBlock = commercialSegment.contact?.cardBlock else {
            return .error(StringErrorOutput(nil))
        }
        let output = GetContactPhonesUseCaseOutput(cardBlock: cardBlock, fraude: fraude)
        return .ok(output)
    }
}

public struct GetContactPhonesUseCaseOutput {
    let cardBlock: ContactPhoneRepresentable
    let fraude: ContactPhoneRepresentable
    
    public init(cardBlock: ContactPhoneRepresentable, fraude: ContactPhoneRepresentable) {
        self.cardBlock = cardBlock
        self.fraude = fraude
    }
}

extension GetContactPhonesUseCase: GetContactPhonesUseCaseProtocol { }
