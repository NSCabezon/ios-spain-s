import UIKit

enum WidgetRowInfo {
    case title(String)
    case transaction(day: String?, month: String?, title: String, amount: String)
    case message(String)
    case lineMessage(String)
}

protocol WidgetAccountInfoDataProviderProtocol: AnyObject, RefreshCapable {
    var accountTitle: String? { get }
    var amountAvailable: String? { get }
    var currentState: String? { get }
    func rows() -> [WidgetRowInfo]
}

final class WidgetAccountInfoView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var listStackView: UIStackView!
    @IBOutlet weak var loadingImageView: WidgetLoading!
        
    private weak var dataProvider: WidgetAccountInfoDataProviderProtocol? {
        didSet {
            setupViews()
            refreshData()
        }
    }
    
    func setDataProvider(_ dataProvider: WidgetAccountInfoDataProviderProtocol) {
        self.dataProvider = dataProvider
    }
    
    private func setupViews() {
        separatorView.backgroundColor = UIColor.sanGreyMedium.withAlphaComponent(0.5)
        titleLabel.font = UIFont.latoBold(size: 14.0)
        stateLabel.font = UIFont.latoRegular(size: 10.0)
        subTitleLabel.font = UIFont.latoBold(size: 20.0)
        refreshButton.addTarget(self, action: #selector(requestUpdate), for: .touchUpInside)
        setColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColors()
    }
    
    @objc func requestUpdate() {
        dataProvider?.updateData()
    }
}

extension WidgetAccountInfoView: Refreshable {
    
    func updateRefreshButton(_ refreshState: RefreshType?) {
        guard let refreshState = refreshState else {
            refreshButton.isHidden = true
            loadingImageView.isHidden = true
            return
        }
        switch refreshState {
        case .available:
            refreshButton.isHidden = false
            loadingImageView.isHidden = true
        case .loading:
            refreshButton.isHidden = true
            loadingImageView.isHidden = false
        case .notAvailable:
            refreshButton.isHidden = true
            loadingImageView.isHidden = true
        }
    }
    
    private func refreshRow(row: WidgetRowInfo) {
        switch row {
        case let .title(title):
            guard let view = WidgetTitleRowView.initFromNib() else { return }
            view.setTitle(title)
            listStackView.addArrangedSubview(view)
        case let .transaction(day: day, month: month, title: title, amount: amount):
            guard let view = WidgetTransactionRowView.initFromNib() else { return }
            view.setDate(day: day, month: month)
            view.setTitle(title)
            view.setAmount(amount)
            listStackView.addArrangedSubview(view)
        case let .message(text):
            guard let view = WidgetMessageRowView.initFromNib() else { return }
            view.setMessage(text)
            listStackView.addArrangedSubview(view)
        case let .lineMessage(text):
            guard let view = WidgetLineMessageRowView.initFromNib() else { return }
            view.setMessage(text)
            listStackView.addArrangedSubview(view)
        }
    }
        
    func refreshData() {
        titleLabel.text = dataProvider?.accountTitle?.uppercased()
        subTitleLabel.text = dataProvider?.amountAvailable
        subTitleLabel.scaleDecimals()
        stateLabel.text = dataProvider?.currentState
        for view in listStackView.arrangedSubviews {
            listStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        updateRefreshButton(dataProvider?.refresh)
        guard let rows = dataProvider?.rows() else { return }
        for row in rows {
            refreshRow(row: row)
        }
    }
}

private extension WidgetAccountInfoView {
    func setColors() {
        titleLabel.textColor = fontColorMode
        stateLabel.textColor = fontColorMode
        subTitleLabel.textColor = fontColorMode
    }
}
