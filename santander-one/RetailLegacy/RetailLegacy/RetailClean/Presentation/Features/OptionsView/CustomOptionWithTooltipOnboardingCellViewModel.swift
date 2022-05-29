import Foundation

struct CustomOptionWithTooltipOnboardingCellViewModel {
    let content: CustomOptionWithTooltipContentOnboarding
    let iconName: String
    let iconTextKey: String
    let tooltipKey: String
    let tooltipImage: String
    let separatorViewVisible: Bool
    let switchState: Bool
    weak var presenter: ToolTipablePresenter?
}
