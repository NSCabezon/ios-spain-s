import CoreFoundationLib

struct EnvironmentSelectorViewModel {
    var title: LocalizedStylableText
    var selected: EnvironmentViewModel
    var environments: [EnvironmentViewModel]
    
    init(title: LocalizedStylableText, selected: EnvironmentViewModel? = nil, environments: [EnvironmentViewModel]) {
        self.title = title
        self.environments = environments
        if let selected = selected {
            self.selected = selected
        } else {
            self.selected = environments.first!
        }
    }
    
    static func == (lhs: EnvironmentSelectorViewModel, rhs: EnvironmentSelectorViewModel) -> Bool {
        return lhs.title.text == rhs.title.text
    }
}
