import UIKit
import UI

protocol GenericLandingPushPresenterProtocol {
    var mainOption: LocalizedStylableText { get }
    func closePressed()
    func didPressMainOption()
}

protocol GenericLandingPushOptionType: Executable {
    var title: LocalizedStylableText { get }
    var imageKey: String { get }
}

protocol GenericLandingPushHeaderType {
    var title: LocalizedStylableText? { get }
    var subtitle: LocalizedStylableText { get }
    var amount: String? { get }
    var detailInfo: [GenericLandingInfoLineType] { get }
}

class GenericLandingPushViewController: BaseViewController<GenericLandingPushPresenterProtocol> {
    @IBOutlet weak var optionsStackView: UIStackView!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var buttonOptionsView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerLandingImageView: UIImageView!
    @IBOutlet weak var sanButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override class var storyboardName: String {
        return "GenericLangdingPush"
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        presenter.closePressed()
    }
    
    @IBAction func logoButtonPressed(_ sender: Any) {
        presenter.closePressed()
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .paleGray
        bottomSeparatorView.backgroundColor = .lisboaGray
        let mainOptionView = WhiteButtonOptionView()
        mainOptionView.translatesAutoresizingMaskIntoConstraints = false
        mainOptionView.setButtonTitle(presenter.mainOption)
        mainOptionView.embedInto(container: buttonOptionsView)
        mainOptionView.delegate = self

        if #available(iOS 11.0, *) {
            let topSpace: CGFloat = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
            topConstraint.constant = 40 + topSpace
        }
        headerLandingImageView.image = Assets.image(named: "img_header_landing")
        sanButton.setImage(Assets.image(named: "icnSanWhiteShadowed")?.withRenderingMode(.alwaysOriginal), for: .normal)
        closeButton.setImage(Assets.image(named: "icnCloseLandingShadowed")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func setDetail(_ detail: GenericLandingPushHeaderType) {
        let headerView = GenericLandingPushHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.setupWith(detail)
        headerView.embedInto(container: headerContainerView)
        let detailView = GenericLandingPushDescriptionView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        detailView.setupWith(detail.detailInfo)
        headerView.setBackgroundedContent(detailView)
    }
    
    func setOptions(_ options: [GenericLandingPushOptionType]) {
        for (index, option) in options.enumerated() {
            let optionView = GenericLandingOptionView()
            optionView.setupWith(option)
            optionsStackView.addArrangedSubview(optionView)
            if index == options.count - 1 {
                optionView.setAsLastOption(true)
            }
        }
    }
}

struct GenericLandingPushHeader: GenericLandingPushHeaderType {
    let title: LocalizedStylableText?
    let subtitle: LocalizedStylableText
    let amount: String?
    let detailInfo: [GenericLandingInfoLineType]
}

extension GenericLandingPushViewController: WhiteButtonOptionViewDelegate {
    func didTapInOpenApp() {
        presenter.closePressed()
    }
}
