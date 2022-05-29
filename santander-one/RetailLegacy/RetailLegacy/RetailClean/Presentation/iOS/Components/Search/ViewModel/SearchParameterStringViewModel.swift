import Foundation
import CoreFoundationLib

protocol SearchCriteriaDelegate: ProductLauncherPresentationDelegate {
    var errorHandler: UseCaseErrorHandler? { get }
    func searchWithCriteria(_ criteria: SearchCriteria)
    func searchButtonWasTapped(text: String?, criteria: SearchCriteria?)
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate)
}

class SearchParameterStringViewModel: TableModelViewItem<SearchParameterStringTableViewCell>, Clearable {
    
    var enteredString: ((String?) -> Void)?
    var currentString: String?
    var modelSearchCriteria = SearchCriteria.none
    var searchAction: ((SearchCriteria) -> Void)?
    private var clearData: (() -> Void)?
    weak var delegate: SearchCriteriaDelegate?
    
    override func bind(viewCell: SearchParameterStringTableViewCell) {
        let stringLoader = dependencies.stringLoader
        viewCell.title(stringLoader.getString("search_button_searchName"))
        viewCell.subTitle(stringLoader.getString("search_label_maxValue"))
        viewCell.searchButtonTitle(stringLoader.getString("search_button_search"))
        viewCell.inputString = currentString
        
        viewCell.textFieldDidChange = { [weak self] newInput in
            self?.currentString = newInput
            self?.enteredString?(newInput)
        }
        viewCell.searchPressed = { [weak self] in
            guard let criteria = self?.modelSearchCriteria else { return }
            self?.searchAction?(criteria)
        }
        clearData = { [weak viewCell] in
            viewCell?.inputString = nil
        }
    }
    
    func clear() {
        clearData?()
    }

}
