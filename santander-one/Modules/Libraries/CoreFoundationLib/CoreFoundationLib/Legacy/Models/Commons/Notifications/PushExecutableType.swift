public enum PushExecutableType: Hashable {
    case otp
    case webview
    case extUrl
    case cardTransaction
    case accountTransaction
    case dialog
    case normal
    case custom(String)
}
