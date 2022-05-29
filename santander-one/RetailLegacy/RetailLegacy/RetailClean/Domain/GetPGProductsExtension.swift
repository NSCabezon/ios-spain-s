import CoreFoundationLib
import SANLegacyLibrary


protocol GettingGPWrapperCapable {
    func getGPWrapper(_ appRepository: AppRepository, _ bsanManagersProvider: BSANManagersProvider, _ accountDescriptorRepository: AccountDescriptorRepository, _ appConfigRepository: AppConfigRepository) throws -> GlobalPositionWrapper?
}

extension GettingGPWrapperCapable {
    func getGPWrapper(_ appRepository: AppRepository, _ bsanManagersProvider: BSANManagersProvider, _ accountDescriptorRepository: AccountDescriptorRepository, _ appConfigRepository: AppConfigRepository) throws -> GlobalPositionWrapper? {
        let merger = try GlobalPositionPrefsMerger(bsanManagersProvider: bsanManagersProvider, appRepository: appRepository, accountDescriptorRepository: accountDescriptorRepository, appConfigRepository: appConfigRepository).merge()
        return merger.globalPositionWrapper
    }
}
