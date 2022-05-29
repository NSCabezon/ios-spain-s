import UIKit
import UI
import CoreFoundationLib

public protocol TransferSubTypeSelectorViewProtocol: AnyObject, LoadingViewPresentationCapable {
    func showTransferSubTypes(types: [TransferSubTypeItemViewModel], addDisclaimerView: Bool)
    func update(_ viewModel: TransferSubTypeItemViewModel)
    func addPackageTransfer(transferPackage: TransferPackageViewModel)
    func addHireTransferPackage()
    func showCommissions()
    func hideCommissions()
}

public class TransferSubTypeSelectorViewController: UIViewController {
    @IBOutlet weak var stackContentView: UIView!
    @IBOutlet weak var continueButton: WhiteLisboaButton!
    @IBOutlet weak var topSeparatorView: UIView!
    var instantView: TransferSubTypeItemView?
    private lazy var stackViewCommissionTitleLabel: UILabel = {
        let title = UILabel()
        title.setSantanderTextFont(type: .regular, size: 12, color: .mediumSanGray)
        title.configureText(withKey: "sendType_label_commission")
        title.textAlignment = .right
        title.accessibilityIdentifier = AccessibilityTransferSubTypes.commissionTitle.rawValue
        return title
    }()
    private lazy var stackViewDisclaimerLabel: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.setSantanderTextFont(type: .regular, size: 12, color: .mediumSanGray)
        title.configureText(withKey: "sendType_disclaimer_commissions")
        title.accessibilityIdentifier = AccessibilityTransferSubTypes.commissionDisclaimer.rawValue
        return title
    }()
    lazy var stackView: ScrollableStackView = {
        let stackView = ScrollableStackView()
        stackView.setup(with: self.stackContentView)
        stackView.setSpacing(9)
        return stackView
    }()
    lazy var asteriskLabel: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.setSantanderTextFont(type: .regular, size: 12, color: .mediumSanGray)
        title.text = "*"
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    let presenter: TransferSubTypeSelectorPresenterProtocol
    var subTypeViews: [TransferSubTypeItemView] {
        self.stackView.getArrangedSubviews().compactMap({ $0 as? TransferSubTypeItemView })
    }
    private var transferPackageView: TransferPackageView?

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,
         presenter: TransferSubTypeSelectorPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(presenter: TransferSubTypeSelectorPresenterProtocol) {
        self.init(nibName: "TransferSubTypeSelector", bundle: .module, presenter: presenter)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
    }
    
    @objc func continueButtonSelected() {
        self.presenter.didSelectContinue()
    }
}

extension TransferSubTypeSelectorViewController: TransferSubTypeSelectorViewProtocol {
    public func showCommissions() {
        self.stackViewCommissionTitleLabel.isHidden = false
        self.stackViewDisclaimerLabel.isHidden = false
        self.asteriskLabel.isHidden = false
    }
    
    public func hideCommissions() {
        self.stackViewCommissionTitleLabel.isHidden = true
        self.stackViewDisclaimerLabel.isHidden = true
        self.asteriskLabel.isHidden = true
    }
    
    public func showTransferSubTypes(types: [TransferSubTypeItemViewModel], addDisclaimerView: Bool) {
        self.addArrangedSubview(self.stackViewTitleLabel)
        self.addArrangedSubview(self.stackViewCommissionTitleLabel)
        types.map(subTypeItemView).forEach(self.stackView.addArrangedSubview)
        if addDisclaimerView == true { self.addArrangedSubview(self.stackViewDisclaimerView) }
    }
    
    public func addPackageTransfer(transferPackage: TransferPackageViewModel) {
        self.instantView?.hideSeparatorView()
        self.transferPackageView = TransferPackageView(frame: .zero, viewModel: transferPackage)
        guard let transferPackageView = self.transferPackageView else {
            return
        }
        self.transferPackageView?.setTooltipWarning(typeValue: .standard)
        self.addArrangedSubview(transferPackageView)
    }
    
    public func addHireTransferPackage() {
        self.instantView?.hideSeparatorView()
        let view = TransferPackageHireView(frame: .zero, delegate: self)
        self.addArrangedSubview(view)
    }
    
    public func update(_ viewModel: TransferSubTypeItemViewModel) {
        let subTypeView = self.subTypeViews.first {
            $0.viewModel == viewModel
        }
        subTypeView?.setup(with: viewModel)
    }
}

extension TransferSubTypeSelectorViewController: TransferSubTypeItemViewDelegate {
    
    func transferSubTypeItemViewSelected(_ view: TransferSubTypeItemView, viewModel: TransferSubTypeItemViewModel) {
        self.presenter.didSelectSubType(viewModel)
        self.transferPackageView?.setTooltipWarning(typeValue: viewModel.typeValue)
    }
}

extension TransferSubTypeSelectorViewController: TransferPackageHireViewDelegate {
    
    func transferPackageHireViewSelected(_ view: TransferPackageHireView) {
        self.presenter.didSelectHireTransferPackage()
    }
}

private extension TransferSubTypeSelectorViewController {
    var stackViewTitleLabel: UILabel {
        let title = UILabel()
        title.numberOfLines = 0
        title.setSantanderTextFont(type: .regular, size: 18, color: .lisboaGray)
        title.configureText(withKey: "sendMoney_label_sentType")
        title.accessibilityIdentifier = AccessibilityTransferSubTypes.viewTitle.rawValue
        return title
    }
    var stackViewDisclaimerView: UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.asteriskLabel)
        self.asteriskLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.asteriskLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.asteriskLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.asteriskLabel.widthAnchor.constraint(equalToConstant: 10).isActive = true
        stackView.addArrangedSubview(view)
        stackView.addArrangedSubview(self.stackViewDisclaimerLabel)
        return stackView
    }

    func addArrangedSubview(_ view: UIView) {
        let containerView = UIView()
        containerView.addSubview(view)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.fullFit(leftMargin: 16, rightMargin: 16)
        self.stackView.addArrangedSubview(containerView)
    }
    
    func setupView() {
        self.continueButton.setTitle(localized("generic_button_continue"), for: .normal)
        self.continueButton.accessibilityIdentifier = AccessibilityOthers.btnContinue.rawValue
        self.continueButton.addSelectorAction(target: self, #selector(continueButtonSelected))
        self.topSeparatorView.backgroundColor = .white
    }
    
    func subTypeItemView(from viewModel: TransferSubTypeItemViewModel) -> TransferSubTypeItemView {
        let view = TransferSubTypeItemView(frame: .zero, viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.accessibilityIdentifier = viewModel.typeAccessibilityId
        switch viewModel.typeValue {
        case .instant:
            self.instantView = view
        default: break
        }
        return view
    }
}
