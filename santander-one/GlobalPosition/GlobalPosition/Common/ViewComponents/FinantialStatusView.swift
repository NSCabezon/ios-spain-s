import UIKit
import UI
import CoreFoundationLib

class FinantialStatusView: DesignableView {
    @IBOutlet weak var leftInfo: AmountButtonWithToolTip!
    @IBOutlet weak var rightInfo: AmountButton!
    
    func setLeftAction(_ action: (() -> Void)?) {
        leftInfo.onTapAction = action
    }
    
    func setRightAction(_ action: (() -> Void)?) {
        rightInfo.onTapAction = action
    }
    
    func setRightSelected() {
        rightInfo.setSelected(isSelected: true)
        leftInfo.setSelected(isSelected: false)
    }
    
    func setLeftSelected() {
        rightInfo.setSelected(isSelected: false)
        leftInfo.setSelected(isSelected: true)
    }
    
    func setLeftData(title: NSAttributedString?, subtitle: NSAttributedString?, tooltipStyle: TooltipType, tooltipText: String) {
        UIView.transition(with: leftInfo, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.leftInfo.setTitle(title)
            self?.leftInfo.setSubtitle(subtitle)
            self?.leftInfo.setTooltipStyle(tooltipStyle)
            self?.leftInfo.setTooltipText(tooltipText)
        }, completion: { [weak self] _ in
            self?.leftInfo.setNeedsLayout()
        })
    }
    
    func setRightData(title: NSAttributedString?, subtitle: NSAttributedString?) {
        UIView.transition(with: rightInfo, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.rightInfo.setTitle(title)
            self?.rightInfo.setSubtitle(subtitle)
            }, completion: { [weak self] _ in
            self?.rightInfo.setNeedsLayout()
        })
    }
    
    func setDiscreteMode(_ enabled: Bool) {
        leftInfo.setDiscreteMode(enabled)
        rightInfo.setDiscreteMode(enabled)
    }
}
