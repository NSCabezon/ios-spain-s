import CoreFoundationLib
import UIKit

class LoadAppInfoVersionsUseCase: UseCase<Void, LoadAppInfoVersionsOkOutput, LoadAppInfoVersionsErrorOutput> {
    
    private let appInfoRepository: AppInfoRepository
    
    init(appInfoRepository: AppInfoRepository) {
        self.appInfoRepository = appInfoRepository
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadAppInfoVersionsOkOutput, LoadAppInfoVersionsErrorOutput> {

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let osVersion = UIDevice.current.systemVersion
        
        let appInfoDTO = appInfoRepository.get() ?? AppInfoDTO(versions: ["": ["": ""]])

        let appInfo = AppInfoDO(dto: appInfoDTO, osVersion: osVersion, appVersion: appVersion)
        return UseCaseResponse.ok(LoadAppInfoVersionsOkOutput(appInfo: appInfo))
    }
}

struct LoadAppInfoVersionsOkOutput {
    let appInfo: AppInfoDO
}

class LoadAppInfoVersionsErrorOutput: StringErrorOutput {
}
