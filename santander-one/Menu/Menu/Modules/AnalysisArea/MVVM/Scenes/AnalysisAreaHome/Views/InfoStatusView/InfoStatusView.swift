//
//  InfoStatusXibView.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 18/2/22.
//

import UI
import UIKit
import OpenCombine
import CoreDomain
import UIOneComponents
import SANLegacyLibrary
import CoreFoundationLib

final class InfoStatusView: XibView {
    
    @IBOutlet private weak var headerStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleView: UIView!
    @IBOutlet private weak var loadingGetStatusView: UIView!
    @IBOutlet private weak var loadingGetStatusImageView: UIImageView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var errorView: UIView!
    @IBOutlet private weak var notificationView: UIView!
    private var subject = PassthroughSubject<UpdateButtonErrorAction, Never>()
    public var publisher: AnyPublisher<UpdateButtonErrorAction, Never> {
        return subject.eraseToAnyPublisher()
    }
    private var subscriptions = Set<AnyCancellable>()
    private lazy var oneNotificationView: OneNotificationsView = {
        let view = OneNotificationsView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
    
    func setStatusInfo(_ representable: FinancialHealthProductsStatusRepresentable) {
        var entitiesDataRepresented = [EntityDataRepresented]()
        representable.entitiesData?.forEach({
            entitiesDataRepresented.append(EntityDataRepresented(company: $0.company, status: $0.status, message: $0.message))
        })
        let infoStatusRepresented = InfoStatusRepresented(lastUpdatedDate: representable.lastUpdatedDate, status: representable.status, entitiesData: entitiesDataRepresented)
        subtitleLabel.text = infoStatusRepresented.statusInfoString
        subtitleLabel.accessibilityLabel = infoStatusRepresented.statusInfoAccessibilityLabel
        if infoStatusRepresented.isErrorViewShown {
            showStatusErrorView(statusErrorTitle: infoStatusRepresented.statusErrorString)
        }
        
        subject.send(.updateProducts(infoStatusRepresented.mustUpdateEntityWithCodes))
    }
    
    func showGetStatusLoadingView() {
        loadingGetStatusView.isHidden = false
        loadingGetStatusImageView.startAnimating()
    }
    
    func hideGetStatusLoadingView() {
        loadingGetStatusView.isHidden = true
        loadingGetStatusImageView.stopAnimating()
    }
    
    func showUpdateStatusErrorView() {
        let oneNotificationViewRepresented = OneNotificationViewRepresented(type: .textAndLink(stringKey: "analysis_label_alertDataOutdated",
                                                                            linkKey: "generic_button_update", linkIsEnabled: true),
                                                                            defaultColor: .onePaleYellow,
                                                                            inactiveColor: nil)
        oneNotificationView.setNotificationView(with: oneNotificationViewRepresented)
        oneNotificationView.removeFromSuperview()
        notificationView.addSubview(oneNotificationView)
        oneNotificationView.fullFit()
        errorView.isHidden = false
    }
    
    func showNetworkErrorView() {
        let oneNotificationViewRepresented = OneNotificationViewRepresented(type: .textOnly(stringKey: "analysis_label_alertConnectionError"),
                                                                            defaultColor: .onePaleYellow,
                                                                            inactiveColor: nil)
        oneNotificationView.setNotificationView(with: oneNotificationViewRepresented)
        oneNotificationView.removeFromSuperview()
        notificationView.addSubview(oneNotificationView)
        oneNotificationView.fullFit()
        errorView.isHidden = false
        subtitleView.isHidden = true
    }
}

private extension InfoStatusView {
    func bind() {
        bindOneNotificationView()
    }
    
    func bindOneNotificationView() {
        oneNotificationView
            .publisher
            .case(OneNotificationState.didTappedLink)
            .sink { [unowned self] _ in
                errorView.isHidden = true
                subject.send(.updateStatus)
            }.store(in: &subscriptions)
    }
    
    func setupView() {
        setupHeader()
        setupLoadingView()
        setAccessibilityIdentifiers()
    }
    
    func setupHeader() {
        view?.backgroundColor = .oneWhite
        headerStackView.backgroundColor = .oneWhite
        titleLabel.text = localized("analysis_label_categoriesTitle")
        titleLabel.font = .typography(fontName: .oneH200Bold)
        titleLabel.textColor = .oneLisboaGray
        subtitleLabel.font = .typography(fontName: .oneB300Regular)
        subtitleLabel.textColor = .oneBrownishGray
    }
    
    func setupLoadingView() {
        loadingGetStatusImageView.setNewJumpingLoader(accessibilityIdentifier: AnalysisAreaAccessibility.analysisViewSmallLoader)
    }
    
    func showStatusErrorView(statusErrorTitle: String) {
        let oneNotificationViewRepresented = OneNotificationViewRepresented(type: .textOnly(stringKey: statusErrorTitle),
                                                                            defaultColor: .onePaleYellow,
                                                                            inactiveColor: nil)
        oneNotificationView.setNotificationView(with: oneNotificationViewRepresented)
        oneNotificationView.removeFromSuperview()
        notificationView.addSubview(oneNotificationView)
        oneNotificationView.fullFit()
        errorView.isHidden = false
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisLabelCategoriesTitle
        subtitleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisLabelLastUpdate
    }
}

struct InfoStatusRepresented {
    var lastUpdatedDate: Date?
    var status: String?
    var entitiesData: [EntityDataRepresented]?
}

struct EntityDataRepresented {
    var company: String?
    var status: String?
    var message: String?
}

extension InfoStatusRepresented: InfoStatusViewRepresentable {
    var statusInfoString: String {
        if let lastUpdatedDate = lastUpdatedDate {
            let dateString = DateFormats.toString(date: lastUpdatedDate, output: .DDMM)
            let timeString = DateFormats.toString(date: lastUpdatedDate, output: .HHmm)
            if lastUpdatedDate.isDayInToday() {
                return localized("analysis_label_lastUpdateToday", [StringPlaceholder(.value, timeString)]).text
            } else if lastUpdatedDate.isDayInYesterday() {
                return localized("analysis_label_lastUpdateYesterday", [StringPlaceholder(.value, timeString)]).text
            } else {
                return localized("analysis_label_lastUpdate", [StringPlaceholder(.value, dateString + " " + timeString)]).text
            }
        } else { return "" }
    }
    
    var statusErrorString: String {
        if status == "KO", let entitiesData = entitiesData, entitiesData.contains(where: { $0.message == "unexpected" || $0.message == "timeout" }) {
            return localized("analysis_label_alertSyncError")
        } else if status == "KO", let entitiesData = entitiesData, entitiesData.contains(where: { $0.message == "credentials" }) {
            return localized("analysis_label_alertCheckCredentials")
        } else { return "" }
    }
    
    var isErrorViewShown: Bool {
        status == "KO"
    }
    
    var mustUpdateEntityWithCodes: [String] {
        var entityCodesKO: [String] = []
        guard let entitiesData = entitiesData else { return entityCodesKO }
        entitiesData.forEach {
            if let entityCompany = $0.company, $0.status == "KO", $0.message != "credentials" {
                entityCodesKO.append(entityCompany)
            }
        }
        return entityCodesKO
    }
    
    var statusInfoAccessibilityLabel: String? {
        if let lastUpdate = lastUpdatedDate {
            let shortDate = lastUpdate.toString(TimeFormat.HHmm.rawValue)
            let longDate = lastUpdate.toString(TimeFormat.dd_MMMM_yyyy_comma_HHmm.rawValue)
            if lastUpdate.isDayInToday() {
                return localized("analysis_label_updatedToday", [StringPlaceholder(.value, ",\(shortDate)")]).text
            } else if lastUpdate.isDayInYesterday() {
                return localized("analysis_label_updatedYesterday", [StringPlaceholder(.value, ",\(shortDate)")]).text
            }
            return localized("analysis_label_updated", [StringPlaceholder(.value, longDate)]).text
        }
        return nil
    }
}

enum UpdateButtonErrorAction {
    case updateStatus
    case updateProducts([String])
    case none
}
