import Foundation

struct ActivateAndChangeSignatureOperativeData {
    let newSignature: String
    let successDialogTitle: LocalizedStylableText
    let successDialogMessage: LocalizedStylableText
    let successAcceptTitle: LocalizedStylableText
    let type: SettingOption
}

extension ActivateAndChangeSignatureOperativeData: OperativeParameter {}
