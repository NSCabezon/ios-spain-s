import Foundation
import CoreFoundationLib

class FirstOnboardingPermissionsUseCase: UseCase<Void, FirstOnboardingPermissionsUseCaseOkOutput, StringErrorOutput> {
    private let dependencies: PresentationComponent
    private let dependenciesResolver: DependenciesResolver
    
    init(dependencies: PresentationComponent, dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependencies
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<FirstOnboardingPermissionsUseCaseOkOutput, StringErrorOutput> {
        let permissionsStatusWrapper: PermissionsStatusWrapperProtocol = self.dependenciesResolver.resolve(for: PermissionsStatusWrapperProtocol.self)
        let result: [FirstBoardingPermissionTypeItem] = permissionsStatusWrapper.getPermissions()
        return UseCaseResponse.ok(FirstOnboardingPermissionsUseCaseOkOutput(items: result))
    }
}

struct FirstOnboardingPermissionsUseCaseOkOutput {
    let items: [FirstBoardingPermissionTypeItem]
}
