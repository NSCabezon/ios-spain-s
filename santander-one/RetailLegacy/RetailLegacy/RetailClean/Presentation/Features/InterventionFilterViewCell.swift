import UIKit
import UI

class InterventionFilterViewCell: BaseViewCell {
    
    @IBOutlet weak var selectionButton: ResponsiveButton!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var spinnerButton: ResponsiveButton!
    @IBOutlet weak var optionsContainer: UIView!
    @IBOutlet weak var containerSeparator: UIView!
    @IBOutlet weak var optionsStack: UIStackView!
    
    var options: [LocalizedStylableText]!
    var selectedOption: Int? {
        didSet {
            setupOptionViews()
        }
    }
    var spinnerTouched: ((InterventionFilterViewCell) -> Void)!
    var selectionDone: ((InterventionFilterViewCell) -> Void)!
    
    private struct Colors {
        static var defaultColor: UIColor = .sanGreyMedium
        static var highlightedColor: UIColor = .sanRed
    }
    
    private var collapsed: Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()
    
        selectionButton.onTouchAction = { [weak self] button in
            guard let self = self else { return }
            self.spinnerTouched(self)
        }
        
        titleLabel.font = .latoRegular(size: 14.0)
        titleLabel.textColor = .sanGreyMedium
        
        spinnerButton.setImage(Assets.image(named: "icnArrowUpPG"), for: .normal)
        spinnerButton.titleLabel?.font = .latoBold(size: 14.0)
        spinnerButton.setTitleColor(.sanRed, for: .normal) 
        
        containerSeparator.backgroundColor = .sanGreyMedium
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func set(spinnerTitle title: LocalizedStylableText) {
        spinnerButton.set(localizedStylableText: title, state: .normal)
    }
    
    func set(imageUp flag: Bool) {
        spinnerButton.imageView?.transform = flag ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
    }
    
    func drawOptions(draw: Bool) {
        optionsStack.subviews.forEach { $0.removeFromSuperview() }
        
        guard draw else {
            return
        }
        
        createOptionViews()
        setupOptionViews()
    }
    
    private func createOptionViews() {
        var index = 0
        
        options.forEach { (option) in
            let view = createViewFor(option: option, withTag: index)
            optionsStack.addArrangedSubview(view)
            
            index += 1
        }
    }
    
    private func createViewFor(option: LocalizedStylableText, withTag tag: Int) -> InterventionFilterOptionView {
        let view = InterventionFilterOptionView.xibVersion
        view.textLabel.set(localizedStylableText: option)
        view.selectionButton.onTouchAction = { button in
            self.selected(option: button.tag)
        }
        view.selectionButton.tag = tag
        
        return view
    }
    
    private func setupOptionViews() {
        let selectedIndex = selectedOption ?? -1
        var index = 0
        
        optionsStack.arrangedSubviews.forEach { view in
            guard let optionView = view as? InterventionFilterOptionView else {
                return
            }
            setup(optionView: optionView, highlighted: index == selectedIndex)
            index += 1
        }
    }
    
    private func setup(optionView view: InterventionFilterOptionView, highlighted: Bool) {
        view.textLabel.font = highlighted ? .latoBold(size: 14.0) : .latoRegular(size: 14.0)
        view.textLabel.textColor = highlighted ? Colors.highlightedColor : Colors.defaultColor
        view.separator.backgroundColor = .lisboaGray
    }
    
    private func selected(option: Int) {
        selectedOption = option
        selectionDone?(self)
    }
}
