//

import Foundation

class GenericHeaderOneLineViewModel: HeaderViewModel<GenericOperativeHeaderOneLineView> {

    let leftTitle: LocalizedStylableText?
    let rightTitle: LocalizedStylableText?
    
    init(leftTitle: LocalizedStylableText?, rightTitle: LocalizedStylableText?) {
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
    }
    
    override func configureView(_ view: GenericOperativeHeaderOneLineView) {
        view.titleLabel.set(localizedStylableText: leftTitle ?? LocalizedStylableText.empty)
        view.amountlabel.set(localizedStylableText: rightTitle ?? LocalizedStylableText.empty)
    }
}
