import Foundation

class SearchParameterButtonViewModel: TableModelViewItem<SearchParameterSearchButtonTableViewCell> {
    
    var searchCriteria: SearchCriteria
    var searchAction: ((SearchCriteria) -> Void)?
    
    init(searchCriteria: SearchCriteria, dependencies: PresentationComponent) {
        self.searchCriteria = searchCriteria
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: SearchParameterSearchButtonTableViewCell) {
        viewCell.setButtonTitle(dependencies.stringLoader.getString("search_button_search"))
        viewCell.buttonPressed = { [weak self] in
            guard let searchCriteria = self?.searchCriteria else { return }
            self?.searchAction?(searchCriteria)
        }
    }
}
