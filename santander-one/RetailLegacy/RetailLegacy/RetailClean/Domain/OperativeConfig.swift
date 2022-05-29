enum OperativeLaunchedFrom {
    case deepLink
    case pg
    case home
    case personalArea
}

protocol OperativeLauncher {
    var origin: OperativeLaunchedFrom { get }
}

struct OperativeConfig {
    var signatureSupportPhone: String?
    var otpSupportPhone: String?
    var cesSupportPhone: String?
    var consultiveUserPhone: String?
    var loanAmortizationSupportPhone: String?
}

extension OperativeConfig: OperativeParameter {}

extension OperativeConfig: Hashable {}
