import UIKit
import NotificationCenter

typealias WidgetButtonData = (title: String, imageKey: String)

protocol TodayWidgetPresenterProtocol {
    var isBiometryAvailable: Bool { get }
    var deeplinkOptions: [WidgetButtonData] { get }
    var currentSection: WidgetSection { get }
    var onUpdate: ((WidgetSection) -> Void)? { get set }
    func didPressDeeplink(_ position: Int)
    func didPressOpenApp()
    func configure(context: NSExtensionContext?)
}

protocol Refreshable {
    func refreshData()
}

final class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var linksStackView: UIStackView!
    @IBOutlet weak var verticalStackView: UIStackView!
    
    lazy var accountInfoView: WidgetAccountInfoView? = {
        let nib = UINib(nibName: "WidgetAccountInfoView",
                        bundle: Bundle(for: type(of: self)))
        return nib.instantiate(withOwner: self, options: nil)[0] as? WidgetAccountInfoView
    }()
    
    lazy var messageLabelView: WidgetMessageLabelView? = {
        let nib = UINib(nibName: "WidgetMessageLabelView",
                        bundle: Bundle(for: type(of: self)))
        return nib.instantiate(withOwner: self, options: nil)[0] as? WidgetMessageLabelView
    }()
    
    private var currentView: (UIView & Refreshable)? = nil
    private var maxWidgetSize: CGSize = .zero
    
    private lazy var presenter: TodayWidgetPresenterProtocol = {
        return WidgetPresenterProvider.todayWidgetPresenter
    }()
    
    private var isSmallScreen: Bool {
        return maxWidgetSize.width < 359
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        presenter.configure(context: extensionContext)
        extensionContext?.widgetLargestAvailableDisplayMode = presenter.isBiometryAvailable ? .expanded : .compact
        buildDeepLinks()
        presenter.onUpdate = { [weak self] section in
            self?.buildDeepLinks()
            self?.buildSections(section)
            self?.currentView?.refreshData()
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.newData)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        maxWidgetSize = maxSize
        let widgetWidth = verticalStackView.bounds.width
        if activeDisplayMode == .expanded {
            buildSections(presenter.currentSection)
        } else {
            self.preferredContentSize = CGSize(width: widgetWidth, height: Constants.compactSize)
        }
    }
    
    //MARK: - Helpers
    
    private func buildDeepLinks() {
        for v in linksStackView.arrangedSubviews {
            linksStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        let options = presenter.deeplinkOptions
        for (index, option) in options.enumerated() {
            let button = WidgetButtonView()
            button.setTitle(option.title, for: .normal)
            button.setImageKey(option.imageKey)
            button.tag = index
            button.titleTextSize = isSmallScreen ? 10 : 12
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            linksStackView.addArrangedSubview(button)
        }
    }
    
    private func updateHeightFor(_ section: WidgetSection) {
        preferredContentSize = CGSize(width: 0, height: Constants.compactSize + heightForSections(section, withMaxSize: maxWidgetSize))
    }
    
    private func heightForSections(_ section: WidgetSection, withMaxSize maxSize: CGSize) -> CGFloat {
        let availableHeight =  maxSize.height - Constants.compactSize
        return section.heightWith(maxHeight: availableHeight)
    }
    
    private func buildSections(_ section: WidgetSection) {
        defer {
            updateHeightFor(section)
        }
        switch section {
        case let .transactionList(dataProvider):
            guard let accountInfoView = accountInfoView, !(currentView === accountInfoView) else { return }
            removeCurrentView()
            accountInfoView.setDataProvider(dataProvider)
            verticalStackView.addArrangedSubview(accountInfoView)
            currentView = accountInfoView
            
            let fGuesture = UITapGestureRecognizer(target: self, action: #selector(stackPressed(_:)))
            verticalStackView.addGestureRecognizer(fGuesture)
            
        case let .message(dataProvider):
            guard let messageView = messageLabelView, currentView != messageLabelView else { return }
            removeCurrentView()
            messageView.setDataProvider(dataProvider)
            verticalStackView.addArrangedSubview(messageView)
            currentView = messageView
        }
    }
    
    private func removeCurrentView() {
        guard let currentView = currentView else { return }
        verticalStackView.removeArrangedSubview(currentView)
        currentView.removeFromSuperview()
    }
    
    @objc func stackPressed(_ sender: AnyObject) {
        presenter.didPressOpenApp()
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        presenter.didPressDeeplink(sender.tag)
    }
}

extension TodayViewController {
    fileprivate struct Constants {
        static let compactSize = CGFloat(110.0)
    }
}

extension WidgetSection {
    func heightWith(maxHeight: CGFloat) -> CGFloat {
        switch self {
        case .message:
            return min(265.0, maxHeight)
        case let .transactionList(dataProvider):
            let headerHeight = CGFloat(75.0)
            let titleHeight = CGFloat(30.0)
            let transactionHeight = CGFloat(38.0)
            let messageHeight = CGFloat(165.0)
            var totalHeight = headerHeight
            
            for row in dataProvider.rows() {
                let rowHeight: CGFloat
                switch row {
                case .title:
                    rowHeight = titleHeight
                case .transaction, .lineMessage:
                    rowHeight = transactionHeight
                case .message:
                    rowHeight = messageHeight
                }
                if totalHeight + rowHeight <= maxHeight {
                    totalHeight += rowHeight
                } else {
                    return totalHeight
                }
            }
            return totalHeight
        }
    }
}

extension UIView {
    var fontColorMode: UIColor {
        return isDark() ? .sanGrey : .sanGreyDark
    }
    
    var fontColorTitleButton: UIColor {
        return isDark() ? .sanGrey : .uiBlack
    }
    
    func isDark() -> Bool {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? true : false
        }
        return false
    }
}
