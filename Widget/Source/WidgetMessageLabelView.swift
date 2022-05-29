import UIKit
import RetailLegacy

enum RefreshType {
    case loading
    case available
    case notAvailable
}

protocol RefreshCapable {
    var refresh: RefreshType { get }
    func updateData()
}

protocol WidgetMessageLabelDataProviderProtocol: AnyObject, RefreshCapable {
    var message: String? { get }
    var actionMessage: String? { get }
    var isActionAvailable: Bool { get }
    func actionPressed()
}

final class WidgetMessageLabelView: UIView {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: WidgetWhiteButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var loadingImageView: WidgetLoading!
    private weak var dataProvider: WidgetMessageLabelDataProviderProtocol?
        
    func setDataProvider(_ dataProvider: WidgetMessageLabelDataProviderProtocol) {
        self.dataProvider = dataProvider
        setupViews()
        refreshData()
    }
    
    private func setupViews() {
        separatorView.backgroundColor = UIColor.sanGreyMedium.withAlphaComponent(0.5)
        messageLabel.font = .latoRegular(size: 12.0)
        setColors()
        refreshButton.addTarget(self, action: #selector(refreshPressed), for: .touchUpInside)
        button.addTarget(self, action: #selector(actionPressed), for: .touchUpInside)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setColors()
    }
    
    @objc func refreshPressed() {
        dataProvider?.updateData()
    }
    
    @objc func actionPressed() {
        dataProvider?.actionPressed()
    }
    
}

extension WidgetMessageLabelView: ViewCreatable {}
extension WidgetMessageLabelView: Refreshable {
    func refreshData() {
        messageLabel.text = dataProvider?.message
        button.isHidden = !(dataProvider?.isActionAvailable ?? false)
        button.setTitle(dataProvider?.actionMessage, for: .normal)
        updateRefreshButton(dataProvider?.refresh)
    }
    
    private func updateRefreshButton(_ refreshState: RefreshType?) {
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
}
private extension WidgetMessageLabelView {
    func setColors() {
        messageLabel.textColor = fontColorMode
    }
}
