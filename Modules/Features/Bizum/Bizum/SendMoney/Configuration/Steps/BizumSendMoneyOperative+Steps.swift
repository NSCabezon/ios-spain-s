import Operative

// MARK: - Steps
extension BizumSendMoneyOperative: OperativeSignatureNavigationCapable {
    var signatureNavigationTitle: String {
        return "toolbar_title_bizum"
    }
}

extension BizumSendMoneyOperative: OperativeOTPNavigationCapable {
    var otpNavigationTitle: String {
        return "toolbar_title_bizum"
    }
}
