import UIKit
import CoreFoundationLib

class TransactionDetailView: UIStackView {
    
    private let viewModel: AccountTransactionDetailViewModel
    
    private struct Constants {
        static let extraInfoSpacing: CGFloat = 0
        static let extraInfoLabelHeight: CGFloat = 18
        static let errorMessageHeight: CGFloat = 40
    }
    
    init(viewModel: AccountTransactionDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        if viewModel.isVisibleBalanceExtraInfo {
            self.addExtraInfoView(("transaction_label_balance", viewModel.accountAmount), identifier: AccessibilityAccountTransactionDetail.allCases[0].rawValue)
        }
        self.addExtraInfo(viewModel.info)
        guard let error = viewModel.error, !error.isEmpty else { return }
        self.addErrorMessage(error)
    }
    
    private func addExtraInfo(_ info: [(String, String)]) {
//        info.forEach(self.addExtraInfoView)
        let identifiers = AccessibilityAccountTransactionDetail.allCases
        info.forEach { detail in
            self.addExtraInfoView(detail, identifier: identifiers[(info.firstIndex(where: { $0.0 == detail.0 }) ?? 0) + 1].rawValue
            )
        }
    }
    
    private func addExtraInfoView(_ detail: (title: String, description: String), identifier: String? = nil) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.extraInfoSpacing
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = localized(detail.title).lowercased().capitalized
        titleLabel.accessibilityIdentifier = (identifier ?? "") + "_title"
        titleLabel.textColor = UIColor.grafite
        titleLabel.font = .santander(family: .text, size: 13)
        titleLabel.heightAnchor.constraint(equalToConstant: Constants.extraInfoLabelHeight).isActive = true
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = detail.description
        valueLabel.accessibilityIdentifier = (identifier ?? "") + "_desc"
        valueLabel.textColor = UIColor.lisboaGray
        valueLabel.font = .santander(family: .text, size: 14)
        valueLabel.numberOfLines = 0
        valueLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.extraInfoLabelHeight).isActive = true
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(valueLabel)
        self.addArrangedSubview(stackView)
    }
    
    private func addErrorMessage(_ message: String) {
        let errorMessageLabel = UILabel()
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.text = message
        errorMessageLabel.textColor = UIColor.lisboaGray
        errorMessageLabel.font = .santander(family: .text, type: .italic, size: 13)
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.heightAnchor.constraint(equalToConstant: Constants.errorMessageHeight).isActive = true
        self.addArrangedSubview(errorMessageLabel)
    }
}
