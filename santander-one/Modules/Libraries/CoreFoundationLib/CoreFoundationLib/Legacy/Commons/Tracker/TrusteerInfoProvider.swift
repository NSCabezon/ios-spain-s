import SANLegacyLibrary

public struct TrusteerInfoProvider {
    public static func getTrusteerInfoWithCustomerSessionId(_ customerSessionId: String, appConfigRepository: AppConfigRepositoryProtocol) -> TrusteerInfoDTO? {
        guard appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteer) == true else { return nil }
        return TrusteerInfoDTO(
            userAgent: "IOS v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")",
            customerSessionId: customerSessionId,
            disabledServicesIP: appConfigRepository.getAppConfigListNode(TrusteerConstants.appConfigIpTrusteerServiceNames) ?? []
        )
    }
}
