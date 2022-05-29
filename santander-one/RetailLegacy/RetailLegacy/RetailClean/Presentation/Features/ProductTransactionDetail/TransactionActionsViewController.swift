import UIKit

protocol TransactionActionsPresenterProtocol {
    func getIndex(_ index: Int)
}

class TransactionActionsViewController: BaseViewController<TransactionActionsPresenterProtocol> {
    @IBOutlet weak var actionsView: UIStackView!
    @IBOutlet weak var actionOneLabel: UILabel!
    @IBOutlet weak var actionTwoLabel: UILabel!
    @IBOutlet weak var actionThreeLabel: UILabel!
    
    var actions: [ProductAction]! {
        didSet {
            configure()
        }
    }
    
    override class var storyboardName: String {
        return "TransactionDetail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionOneLabel.tag = 0
        actionTwoLabel.tag = 1
        actionThreeLabel.tag = 2
    }
    
    override func prepareView() {
        super.prepareView()
                
        actionsView.arrangedSubviews.forEach { $0.drawRoundedAndShadowed() }
        
        let fontSize: CGFloat = UIScreen.main.isIphone4or5 ? 13.0 : 14.0
        
        actionOneLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontSize), textAlignment: .center))
        actionTwoLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontSize), textAlignment: .center))
        actionThreeLabel.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: fontSize), textAlignment: .center))
    }
    
    private func configure() {
        for view in actionsView.arrangedSubviews {
            if actions.contains(where: { $0.index == view.tag }) {
                if let label = view.subviews.first as? UILabel, let index = actions.firstIndex(where: { $0.index == view.tag }) {
                    label.set(localizedStylableText: actions[index].title)
                }
            } else {
                view.isHidden = true
            }
        }
    }
    
    func setHighlightedOptions(_ options: [Int]) {
        let buttons = [actionOneLabel, actionTwoLabel, actionThreeLabel]
        for button in buttons {
            guard let tag = button?.tag else { continue }
            let color = options.contains(tag) ? UIColor.sanRed : UIColor.sanGreyDark
            button?.textColor = color
        }
    }
    
    @IBAction func actionOne(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        presenter.getIndex(tag)
    }
    
    @IBAction func actionTwo(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        presenter.getIndex(tag)
    }
    
    @IBAction func actionThree(_ sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        presenter.getIndex(tag)
    }
    
}
