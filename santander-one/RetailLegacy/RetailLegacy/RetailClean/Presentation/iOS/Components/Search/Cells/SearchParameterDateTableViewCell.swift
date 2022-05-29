import UIKit
import UI

class SearchParameterDateTableViewCell: BaseViewCell, UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleFromLabel: UILabel!
    @IBOutlet weak var titleToLabel: UILabel!
    @IBOutlet weak var dateFromTextField: UITextField!
    @IBOutlet weak var dateToTextField: UITextField!
    var textFieldFromTapped: (() -> Void)?
    var textFieldToTapped: (() -> Void)?

    func title(_ title: LocalizedStylableText) {
        titleLabel.set(localizedStylableText: title)
    }
    func titleFromDate(_ title: LocalizedStylableText) {
        titleFromLabel.set(localizedStylableText: title)
    }
    func titleToDate(_ title: LocalizedStylableText) {
        titleToLabel.set(localizedStylableText: title)
    }
    func dateFrom(_ date: String?) {
        dateFromTextField.text = date
    }
    func dateTo(_ date: String?) {
        dateToTextField.text = date
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        dateFromTextField.delegate = self
        dateToTextField.delegate = self
        titleLabel.font = UIFont.latoBold(size: 16.0)
        titleLabel.textColor = .sanRed
        titleFromLabel.font = UIFont.latoBoldItalic(size: 14.0)
        titleFromLabel.textColor = .sanGreyMedium
        titleToLabel.font = UIFont.latoBoldItalic(size: 14.0)
        titleToLabel.textColor = .sanGreyMedium
        configureTextField(dateFromTextField)
        configureTextField(dateToTextField)
    }
    
    private func configureTextField(_ textField: UITextField) {
        textField.font = UIFont.latoRegular(size: 16.0)
        textField.textColor = .sanGreyDark
        textField.backgroundColor = .white
        let supportImage = UIImageView(image: Assets.image(named: "icnCalendarRetail"))
        supportImage.contentMode = .scaleAspectFit
        textField.rightViewMode = .always
        textField.rightView = supportImage.embedIntoView(
            topMargin: 0,
            bottomMargin: 0,
            leftMargin: 10,
            rightMargin: 10
        )
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateFromTextField {
            textFieldFromTapped?()
        } else {
            textFieldToTapped?()
        }
        return false
    }
}
