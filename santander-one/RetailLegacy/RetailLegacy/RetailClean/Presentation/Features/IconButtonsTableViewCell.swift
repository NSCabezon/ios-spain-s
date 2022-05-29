import UIKit

class IconButtonsTableViewCell: BaseViewCell {

    @IBOutlet weak var button1View: UIView!
    @IBOutlet weak var button2View: UIView!
    @IBOutlet weak var button3View: UIView!
    @IBOutlet var buttonViews: [UIView]!
    @IBOutlet var buttons: [UIButton]!
    private var actions = [(()-> Void)?](repeating: nil, count: 3)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonViews.forEach {
            $0.drawRoundedAndShadowed()
            $0.isHidden = true
        }
        
        buttons.forEach {
            $0.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        }
    }
    
    func setOption(number position: Int, icon: UIImage?, action: (() -> Void)?) {
        guard position < 3 else { return }
        buttons[position].setImage(icon, for: .normal)
        actions[position] = action
        buttonViews[position].isHidden = false
    }
    
    @objc func buttonPressed(sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else {
            return
        }
        actions[index]?()
    }
    
}
