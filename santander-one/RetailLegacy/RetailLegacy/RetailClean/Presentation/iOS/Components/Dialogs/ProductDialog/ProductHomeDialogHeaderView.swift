//

import UIKit

class ProductHomeDialogHeaderView: UIView {
    
    func sectionHeader(_ title: LocalizedStylableText, width: CGFloat) -> UIView {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        contentView.backgroundColor = .uiWhite
        
        let titleSection = UILabel(frame: CGRect(x: 10, y: 20, width: width, height: 22))
        titleSection.applyStyle(LabelStylist.productHomeOptionsTitleSection)
        titleSection.set(localizedStylableText: title)
        
        let bottomMargin = UIView(frame: CGRect(x: 10, y: contentView.frame.height - 2, width: contentView.frame.width - 20, height: 2))
        bottomMargin.backgroundColor = .sanRed
        
        contentView.addSubview(titleSection)
        contentView.addSubview(bottomMargin)
        
        return contentView
    }
}
