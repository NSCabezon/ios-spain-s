import Foundation
import CoreFoundationLib

final class CustomOptionWithTooltipOnboardingViewModel: OnboardingStackItem<CustomOptionWithTooltipOnboardingView> {
    // MARK: - Private attributes
    private let stringLoader: StringLoader
    private let titleKey: String
    private let descriptionKey: String
    private let imageName: String
    private weak var view: CustomOptionWithTooltipOnboardingView?
    private let cellViewModel: [CustomOptionWithTooltipOnboardingCellViewModel]
    private let change: ((CustomOptionWithTooltipContentOnboarding) -> Void)?
    
    // MARK: - Public methods
    
    init(stringLoader: StringLoader,
         titleKey: String,
         descriptionKey: String,
         imageName: String,
         insets: OnboardingStackViewInsets = OnboardingStackViewInsets(left: 0, right: 0, top: 0, bottom: 24),
         cellViewModel: [CustomOptionWithTooltipOnboardingCellViewModel],
         change: ((CustomOptionWithTooltipContentOnboarding) -> Void)?) {
        self.stringLoader = stringLoader
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.imageName = imageName
        self.change = change
        self.cellViewModel = cellViewModel
        super.init(insets: insets)
    }
    
    override func bind(view: CustomOptionWithTooltipOnboardingView) {
        view.set(title: self.stringLoader.getString(self.titleKey), description: self.stringLoader.getString(self.descriptionKey), image: self.imageName)
        let cells = self.addCells(self.cellViewModel)
        _ = cells.map { view.stackView.addArrangedSubview($0) }
        self.view = view
    }
}

private extension CustomOptionWithTooltipOnboardingViewModel {
    func addCells(_ viewModel: [CustomOptionWithTooltipOnboardingCellViewModel]) -> [CustomOptionWithTooltipOnboardingCellView] {
        var cellViews: [CustomOptionWithTooltipOnboardingCellView] = []
        for cellViewModel in viewModel {
            let cellView: CustomOptionWithTooltipOnboardingCellView = CustomOptionWithTooltipOnboardingCellView()
            cellView.setViewModel(cellViewModel)
            cellView.isSwitchOn = cellViewModel.switchState
            cellView.switchValueDidChange = { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.change?(cellViewModel.content)
            }
            cellViews.append(cellView)
        }
        return cellViews
    }
}
