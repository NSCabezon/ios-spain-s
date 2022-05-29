import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class RegisterDeviceUseCase: UseCase<RegisterDeviceInput, RegisterDeviceOkOutput, RegisterDeviceErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appRepository: AppRepository
    private let dependenciesResolver: DependenciesResolver
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }

    init(provider: BSANManagersProvider, appRepository: AppRepository, dependenciesResolver: DependenciesResolver) {
        self.provider = provider
        self.appRepository = appRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: RegisterDeviceInput) throws -> UseCaseResponse<RegisterDeviceOkOutput, RegisterDeviceErrorOutput> {
        let globalPositionDTO = try checkRepositoryResponse(provider.getBsanPGManager().getGlobalPosition())
        let touchIdManager = provider.getBsanTouchIdManager()
        var deviceName = requestValues.deviceName
        let name: String
        if deviceName.count >= 50, let temp = deviceName.substring(0, 49) {
            name = temp
        } else {
            name = deviceName
        }
        let response = try touchIdManager.registerTouchId(footPrint: requestValues.footPrint, deviceName: name)
        
        if response.isSuccess(), let data = try response.getResponseData() {
            try saveTouchId(globalPositionDTO)
            return UseCaseResponse.ok(RegisterDeviceOkOutput(deviceMagicPhrase: data.deviceMagicPhrase ?? "", touchIDLoginEnabled: true, deviceId: data.deviceId ?? ""))
        } else if let errorMessage = try response.getErrorMessage() {
            if errorMessage.trim() == "FACSEG_40000001" {
                deviceName += Date.timeIntervalSinceReferenceDate.description
                
                if deviceName.count >= 50, let temp = deviceName.substring(0, 49) {
                    deviceName = temp
                }
                
                let tryAgainResponse = try touchIdManager.registerTouchId(footPrint: requestValues.footPrint, deviceName: deviceName)
                if tryAgainResponse.isSuccess(), let data = try tryAgainResponse.getResponseData() {
                    try saveTouchId(globalPositionDTO)
                    return UseCaseResponse.ok(RegisterDeviceOkOutput(deviceMagicPhrase: data.deviceMagicPhrase ?? "", touchIDLoginEnabled: true, deviceId: data.deviceId ?? ""))
                }
            }
        }
        
        return try UseCaseResponse.error(RegisterDeviceErrorOutput(response.getErrorMessage() ?? ""))
    }
    
    private func saveTouchId(_ globalPosition: GlobalPositionDTO?) throws {
        if try appRepository.getPersistedUser().getResponseData() == nil, let userType = try appRepository.getTempUserType().getResponseData(), let login = try appRepository.getTempLogin().getResponseData(), let environmentName = try appRepository.getTempEnvironmentName().getResponseData(), let name = try appRepository.getTempName().getResponseData() {
            let user = PersistedUserDTO.createPersistedUser(loginType: userType, login: login, environmentName: environmentName)
            user.name = name
            user.channelFrame = globalPosition?.userDataDTO?.channelFrame
            _ = appRepository.setPersistedUserDTO(persistedUserDTO: user)
        }
        _ = appRepository.setSharedPersistedUser()
        try setFirstTimeBiometricActiveAtUserPreferencesIfNeeded(globalPosition)
    }
    
    private func getUserId(_ globalPosition: GlobalPositionDTO?) -> String? {
        guard let globalPositionDTO = globalPosition else {
            return nil
        }
        let userId = GlobalPosition.createFrom(dto: globalPositionDTO).userId
        return userId
    }
    
    private func setFirstTimeBiometricActiveAtUserPreferencesIfNeeded(_ globalPosition: GlobalPositionDTO?) throws {
        guard let userId = getUserId(globalPosition) else { return }
        let userPreferences = appRepository.getUserPreferences(userId: userId)
        let userPrefEntity = UserPrefEntity.from(dto: userPreferences)
        guard !userPrefEntity.getFirstTimeBiometricCredentialActivated(),
              localAppConfig.enableBiometric else { return }
        userPrefEntity.setFirstTimeBiometricCredentialActive()
        appRepository.setUserPreferences(userPref: userPrefEntity.userPrefDTOEntity)
    }
}

struct RegisterDeviceInput {
    let footPrint: String
    let deviceName: String
}

struct RegisterDeviceOkOutput {
    let deviceMagicPhrase: String
    let touchIDLoginEnabled: Bool
    let deviceId: String
}

class RegisterDeviceErrorOutput: StringErrorOutput {
}
