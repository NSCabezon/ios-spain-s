import UIKit

class AccountSelectorHeaderView: UIView {
    func sectionHeader(_ title: LocalizedStylableText, width: CGFloat) -> UIView {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        contentView.backgroundColor = .uiBackground
        let titleSection = UILabel(frame: CGRect(x: 10, y: 20, width: width, height: 22))
        titleSection.applyStyle(LabelStylist(textColor: .sanGreyDark, font: .latoBold(size: 16.0), textAlignment: .left))
        titleSection.set(localizedStylableText: title)
        contentView.addSubview(titleSection)
        return contentView
    }
}
