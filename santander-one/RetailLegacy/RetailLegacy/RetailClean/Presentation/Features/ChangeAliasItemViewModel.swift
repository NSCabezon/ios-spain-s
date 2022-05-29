//

import Foundation

class ChangeAliasItemViewModel: TableModelViewItem<ChangeAliasTableViewCell> {
    
    weak var delegate: ChangeTextFieldDelegate?
    var maxLength: Int
    var previousAlias: String
    
    init(_ dependencies: PresentationComponent, delegate: ChangeTextFieldDelegate?, maxLength: Int, previousAlias: String) {
        self.delegate = delegate
        self.maxLength = maxLength
        self.previousAlias = previousAlias
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: ChangeAliasTableViewCell) {
        viewCell.infoTitle = dependencies.stringLoader.getString("productDetail_label_alias")
        viewCell.infoSaveButton = dependencies.stringLoader.getString("generic_button_save")
        viewCell.customDelegate = delegate
        viewCell.maxLength = maxLength
        var printedAlias = previousAlias
        if printedAlias.count > maxLength {
            printedAlias = printedAlias[0..<maxLength]
        }

        viewCell.infoTextField = printedAlias
    }
}
