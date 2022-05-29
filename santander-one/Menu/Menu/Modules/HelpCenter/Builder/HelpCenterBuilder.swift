import CoreFoundationLib

class HelpCenterBuilder {
    private var viewModels: [HelpCenterEmergencyItemViewModel] = []
    
    func addImageLabel(viewModel: HelpCenterEmergencyItemViewModel) {
        self.viewModels.append(viewModel)
    }
    
    func build() -> [HelpCenterEmergencyItemViewModel] {
        return viewModels
    }
}
