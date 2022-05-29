import Foundation
import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary

final class UpdateOptionsOnboardingUserPrefUseCase: UseCase<UpdateOptionsOnboardingUserPrefUseCaseInput, Void, StringErrorOutput> {
    
    private let appRepository: AppRepository
    
    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }
    
    override func executeUseCase(requestValues: UpdateOptionsOnboardingUserPrefUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let userPrefDTO = appRepository.getUserPreferences(userId: requestValues.userId)
        
        if let onboardingFinished = requestValues.onboardingFinished {
            userPrefDTO.pgUserPrefDTO.onboardingFinished = onboardingFinished
        }
        
        if let globalPositionOptionSelected = requestValues.globalPositionOptionSelected {
            userPrefDTO.pgUserPrefDTO.globalPositionOptionSelected = globalPositionOptionSelected.value()
        }
        
        if let photoThemeOptionSelected = requestValues.photoThemeOptionSelected {
            userPrefDTO.pgUserPrefDTO.photoThemeOptionSelected = photoThemeOptionSelected.value()
        }
        
        if let smartColor = requestValues.smartColor {
            userPrefDTO.pgUserPrefDTO.pgColorMode = smartColor
        }
        
        if let alias = requestValues.alias {
            userPrefDTO.pgUserPrefDTO.alias = alias
        }
        
        appRepository.setUserPreferences(userPref: userPrefDTO)
        
        return .ok()
    }
}

struct UpdateOptionsOnboardingUserPrefUseCaseInput {
    let userId: String
    let onboardingFinished: Bool?
    let globalPositionOptionSelected: GlobalPositionOption?
    let photoThemeOptionSelected: PhotoThemeOption?
    let smartColor: PGColorMode?
    let alias: String?
}
