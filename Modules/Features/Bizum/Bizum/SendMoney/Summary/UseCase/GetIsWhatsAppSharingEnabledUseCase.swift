//
//  GetIsWhatsappShareEnabledUseCase.swift
//  Bizum
//
//  Created by alvola on 11/01/2021.
//
import CoreFoundationLib

public typealias GetIsWhatsAppSharingEnabledUseCaseAlias = UseCase<Void,
                                                                   GetIsWhatsAppSharingEnabledUseCaseOkOutput,
                                                                   StringErrorOutput>

final public class GetIsWhatsAppSharingEnabledUseCase: GetIsWhatsAppSharingEnabledUseCaseAlias {
    private let appConfigRepository: AppConfigRepositoryProtocol

    public init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve()
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetIsWhatsAppSharingEnabledUseCaseOkOutput, StringErrorOutput> {
        let whatsAppSharingEnabled = appConfigRepository.getBool(BizumConstants.isWhatsAppSharingEnabled) ?? false
        return UseCaseResponse.ok(GetIsWhatsAppSharingEnabledUseCaseOkOutput(isWhatsappSharingEnabled: whatsAppSharingEnabled))
    }
}

public struct GetIsWhatsAppSharingEnabledUseCaseOkOutput {
    public let isWhatsappSharingEnabled: Bool
}
