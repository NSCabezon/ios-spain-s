public protocol SendMoneyHomeTooltipProtocol {
    func getOptions() -> [CustomOptionWithTooltipSendMoneyHome]
}

public class CustomOptionWithTooltipSendMoneyHome {
    let textKey: String
    let iconKey: String
    
    public init(text: String, icon: String) {
        self.textKey = text
        self.iconKey = icon
    }
}
