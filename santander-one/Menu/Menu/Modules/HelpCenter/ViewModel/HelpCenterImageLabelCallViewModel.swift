import CoreFoundationLib

public struct HelpCenterImageLabelCallViewModel {
    let phone: LocalizedStylableText
    public let action: HelpCenterEmergencyAction
    var titleLabelSize: CGFloat
    
    public init(phone: LocalizedStylableText, action: HelpCenterEmergencyAction, titleLabelSize: CGFloat = 12) {
        self.phone = phone
        self.action = action
        self.titleLabelSize = titleLabelSize
    }
}
