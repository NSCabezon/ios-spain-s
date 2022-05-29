import UIKit
import UI
import CoreDomain
import CoreFoundationLib

protocol PullOfferDetailPresenterProtocol {
    func buttonPressed()
    func buttonSelected(action: OfferActionRepresentable?)
}

class PullOfferDetailViewController: BaseViewController<PullOfferDetailPresenterProtocol> {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var whiteButton: WhiteButton!
    @IBOutlet weak var redButton: RedButton!
    
    lazy var dataSource: TableDataSource = {
        let data = TableDataSource()
        return data
    }()
    
    override class var storyboardName: String {
        return "PullOfferDetail"
    }
    
    var titleButton1: LocalizedStylableText? {
        didSet {
            if let text = titleButton1 {
                redButton.set(localizedStylableText: text.uppercased(), state: .normal)
            }
        }
    }
    
    var titleButton2: LocalizedStylableText? {
        didSet {
            if var text = titleButton2 {
                whiteButton.set(localizedStylableText: text.camelCased(), state: .normal)
            }
        }
    }
    
    var sections: [TableModelViewSection] {
        set {
            dataSource.clearSections()
            dataSource.addSections(newValue)
            tableView.reloadData()
        }
        get {
            return dataSource.sections
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .title(key: self.title ?? "")
        )
        builder.setRightActions(
            .close(action: #selector(closeButtonTouched))
        )
        builder.setLeftAction(
            .back(action: #selector(navigateBack))
        )
        builder.build(on: self, with: nil)
    }
    
    override func prepareView() {
        super.prepareView()
        view.backgroundColor = .uiWhite
        separatorView.backgroundColor = .lisboaGray
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.registerCells(["TutorialImageTableViewCell", "OperativeLabelTableViewCell"])
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    func calculateHeight() {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func configureOfferButtons(offerButton1: OfferButton?, offerButton2: OfferButton?) {
        if let offerButton1 = offerButton1 {
            titleButton1 = LocalizedStylableText(text: offerButton1.text, styles: nil)
            redButton.onTouchAction = { [weak self] _ in
                self?.presenter.buttonSelected(action: offerButton1.action)
            }
            if let offerButton2 = offerButton2 {
                titleButton2 = LocalizedStylableText(text: offerButton2.text, styles: nil)
                whiteButton.onTouchAction = { [weak self] _ in
                    self?.presenter.buttonSelected(action: offerButton2.action)
                }
            } else {
                whiteButton.isHidden = true
            }
        } else {
            whiteButton.isHidden = true
            redButton.isHidden = true
            separatorView.isHidden = true
        }
    }
    @objc override func closeButtonTouched() {
        presenter.buttonPressed()
    }
    
    @objc private func navigateBack() {
        presenter.buttonPressed()
    }
}

extension PullOfferDetailViewController: ActionClosableProtocol {}
extension PullOfferDetailViewController: NavigationBarCustomizable {}
