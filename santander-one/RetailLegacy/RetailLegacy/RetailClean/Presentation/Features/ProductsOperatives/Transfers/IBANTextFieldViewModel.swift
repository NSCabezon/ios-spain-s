//

import UIKit
import CoreFoundationLib

class IBANTextFieldCellViewModel: TableModelViewItem<IBANTextFieldTableViewCell>, InputIdentificable {
    
    let inputIdentifier: String
    var dataEntered: String?
    let placeholder: LocalizedStylableText?
    let country: SepaCountryInfo
    var bankingUtils: BankingUtilsProtocol?
    
    init(inputIdentifier: String, placeholder: LocalizedStylableText?, privateComponent: PresentationComponent, country: SepaCountryInfo) {
        self.placeholder = placeholder
        self.inputIdentifier = inputIdentifier
        self.country = country
        super.init(dependencies: privateComponent)
    }
    
    override func bind(viewCell: IBANTextFieldTableViewCell) {
        viewCell.newTextFieldValue = { [weak self] value in
            self?.dataEntered = value
        }
        viewCell.styledPlaceholder = placeholder
        viewCell.info = IBANTextFieldInfo(country: country, length: country.bbanLength)
        viewCell.bankingUtils = bankingUtils
        if let text = dataEntered {
            viewCell.ibanTextField.copyText(text: text)
        }
    }
}
