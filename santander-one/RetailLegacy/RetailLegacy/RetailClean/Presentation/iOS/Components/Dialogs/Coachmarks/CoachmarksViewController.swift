import UIKit
import UI
import CoreDomain

protocol CoachmarkProfile {
    var headerIdentifiers: [CoachmarkIdentifier] { get }
    var transactionIdentifiers: [CoachmarkIdentifier] { get }
    var texts: [CoachmarkIdentifier: String] { get }
    
    var coachmarkToInsertInSearchButton: CoachmarkIdentifier? { get }
    var coachmarkToInsertInFirstSeparator: CoachmarkIdentifier? { get }
    var coachmarkToInsertInSecondSeparator: CoachmarkIdentifier? { get }
    func setNextProduct(index: Int)
}

protocol CoachmarkPresenter: class {
    //EACH COACHMARK PRESENTER NEEDS TO KNOW HOW MANY COACHMARKS NEED TO BE SHOWN IN ORDER TO LAUNCH COACHMARK VIEW CONTROLLER ONCE THEM ALL ARE READY
    var neededIdentifiers: [CoachmarkIdentifier] { get }
    var viewPositions: [CoachmarkIdentifier: IntermediateRect] { get set }
    var texts: [CoachmarkIdentifier: String] { get }
    
    //CHILDREN VIEWS WILL SET THEIR COACHMARK INFO TO PARENT, WHO IS THE ONE IN CHARGE OF PRESENTING COACHMARK VIEW CONTROLLER
    func resetCoachmarks()
    func setCoachmarks(coachmarks: [CoachmarkIdentifier: IntermediateRect], isForcedCoachmark: Bool)
    func coachmarkDidDismiss()
}

extension CoachmarkPresenter {
    func coachmarkDidDismiss() {}
}

class Coachmark {
    static func present(source: UIViewController, presenter: CoachmarkPresenter) {
        let coachmark = CoachmarksViewController(source: source, viewPositions: presenter.viewPositions, texts: presenter.texts)
        coachmark.delegate = presenter
        coachmark.presentDialog()
    }
}

enum AlignMode {
    case centered
    case topAlign
    case bottomAlign
    case leftAlign
    case rightAlign
    
    //ORIGIN Y FOR THE ELEMENTS PLACED LEFT OR RIGHT THE REFERENCE ELEMENT
    func getOriginY(referenceElement: CGRect, elementHeight: CGFloat) -> CGFloat {
        var originY: CGFloat = 0
        switch self {
        case .topAlign:
            originY = referenceElement.origin.y - elementHeight
        case .bottomAlign:
            originY = referenceElement.origin.y + referenceElement.height
        case .centered:
            originY = referenceElement.origin.y + referenceElement.height/2 - elementHeight/2
        default:
            break
        }
        
        return originY
    }
    
    //ORIGIN X FOR THE ELEMENTS PLACED OVER OR UNDER THE REFERENCE ELEMENT
    func getOriginX(referenceElement: CGRect, elementWidth: CGFloat, margin: CGFloat) -> CGFloat {
        var originX: CGFloat = 0
        switch self {
        case .leftAlign:
            originX = referenceElement.origin.x - elementWidth
        case .rightAlign:
            originX = referenceElement.origin.x + referenceElement.width
        case .centered:
            originX = referenceElement.origin.x + referenceElement.width/2 - elementWidth/2
        default:
            break
        }
        
        if originX < margin {
            return 20
        } else if originX + elementWidth > (UIScreen.main.bounds.width - margin) {
            return originX - (originX + elementWidth - (UIScreen.main.bounds.width - margin))
        }
        
        return originX
    }
}

enum ReferencePosition {
    case withoutReference
    case underReference(horizontalAdjust: CGFloat, verticalSeparation: CGFloat, alignMode: AlignMode)
    case overReference(horizontalAdjust: CGFloat, verticalSeparation: CGFloat, alignMode: AlignMode)
    case centeredInScreen(verticalSeparation: CGFloat)
    case toLeftOfReference(horizontalSeparation: CGFloat, verticalAdjust: CGFloat, alignMode: AlignMode)
    case toRightOfReference(horizontalSeparation: CGFloat, verticalAdjust: CGFloat, alignMode: AlignMode)
}

class CoachmarksViewController: UIViewController {
    
    @IBOutlet weak var closeButton: ResponsiveButton!
    @IBOutlet weak var closeButtonTopConstraint: NSLayoutConstraint!
    
    var viewPositions: [CoachmarkIdentifier: CGRect]
    var texts: [CoachmarkIdentifier: String]
    let minimumMargin: CGFloat = 20
    
    private var source: UIViewController? {
        if sourceViewController?.isViewLoaded == true {
            return sourceViewController
        } else {
            let appDelegate = UIApplication.shared.delegate //as? AppDelegate
            let sourceView = appDelegate?.window??.rootViewController
            return sourceView
        }
    }
    fileprivate weak var delegate: CoachmarkPresenter?
    private weak var sourceViewController: UIViewController?
    
    fileprivate init(source: UIViewController, viewPositions: [CoachmarkIdentifier: IntermediateRect], texts: [CoachmarkIdentifier: String]) {
        self.sourceViewController = source
        self.viewPositions = [CoachmarkIdentifier: CGRect]()
        for elem in viewPositions where elem.value != IntermediateRect.zero {
            self.viewPositions[elem.key] = CGRect(x: elem.value.x, y: elem.value.y, width: elem.value.width, height: elem.value.height)
        }
        
        self.texts = texts
        super.init(nibName: "CoachmarksViewController", bundle: .module)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        create()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
        closeButton.onTouchAction = { [weak self] _ in
            self?.dismissView()
        }
        //Old devices
        if UIScreen.main.isIphone4 || UIScreen.main.isIpadNoRetina {
            closeButtonTopConstraint.constant = 25
        }
    }
    
    @objc func dismissView() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.coachmarkDidDismiss()
        }
    }
    
    private func create() {
        
        for position in viewPositions {
            let elementPosition = CGRect(x: position.value.origin.x, y: position.value.origin.y, width: position.value.width, height: position.value.height)
            let finalElementPosition = (elementPosition.origin.y > UIScreen.main.bounds.height)
                ? CGRect(x: elementPosition.origin.x, y: UIScreen.main.bounds.height, width: elementPosition.width, height: elementPosition.height)
                : elementPosition
            let test = UILabel(frame: finalElementPosition)
            
            self.view.addSubview(test)
            
            let arrow = createArrow(coachmarkId: position.key, elementRect: finalElementPosition)
            view.addSubview(arrow)
            
            let label = createLabel(coachmarkId: position.key, arrowRect: arrow.frame)
            view.addSubview(label)
        }
    }
    
    func presentDialog() {
        guard parent == nil, source?.presentedViewController == nil else {
            return
        }
        if let navigationController = source?.navigationController, navigationController.viewControllers.last != source {
            return
        }
        source?.present(self, animated: true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            completion?()
            self.view = nil
        }
    }
    
    //HELPER METHODS
    
    private func getImageSize(imageName: String) -> CGSize {
        let test = UIImageView(frame: CGRect(x: 0, y: 0, width: 350, height: 350))
        test.contentMode = .center
        test.image = Assets.image(named: imageName)
        
        return test.image?.size ?? CGSize.zero
    }
    
    private func getLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height) + 10
    }
    
    private func createArrow(coachmarkId: CoachmarkIdentifier, elementRect: CGRect) -> UIImageView {
        let imageName = getImageName(coachmarkId: coachmarkId)
        let imageSize = getImageSize(imageName: imageName)
        
        let arrowPosition = getArrowPosition(coachmarkId: coachmarkId)
        var originY: CGFloat = 0
        var originX: CGFloat = 0
        
        switch arrowPosition {
        case .toLeftOfReference:
            if case .toLeftOfReference(let horizontalSeparation, let verticalAdjust, let alignMode) = arrowPosition {
                originY = alignMode.getOriginY(referenceElement: elementRect, elementHeight: imageSize.height) + verticalAdjust
                originX = elementRect.origin.x - imageSize.width - horizontalSeparation
            }
        case .toRightOfReference:
            if case .toRightOfReference(let horizontalSeparation, let verticalAdjust, let alignMode) = arrowPosition {
                originY = alignMode.getOriginY(referenceElement: elementRect, elementHeight: imageSize.height) + verticalAdjust
                originX = elementRect.origin.x + elementRect.width + horizontalSeparation
            }
        case .underReference:
            if case .underReference(let horizontalAdjust, let verticalSeparation, let alignMode) = arrowPosition {
                originY = elementRect.origin.y + elementRect.height + verticalSeparation
                originX = alignMode.getOriginX(referenceElement: elementRect, elementWidth: imageSize.width, margin: minimumMargin) + horizontalAdjust
            }
        case .overReference:
            if case .overReference(let horizontalAdjust, let verticalSeparation, let alignMode) = arrowPosition {
                originY = elementRect.origin.y - imageSize.height - verticalSeparation
                originX = alignMode.getOriginX(referenceElement: elementRect, elementWidth: imageSize.width, margin: minimumMargin) + horizontalAdjust
            }
        case .centeredInScreen:
            if case .centeredInScreen(let verticalSeparation) = arrowPosition {
                originY = elementRect.origin.y - imageSize.height - verticalSeparation
                originX = UIScreen.main.bounds.width/2 - imageSize.width/2
            }
        case .withoutReference: break
        }
        
        let arrow = UIImageView(frame: CGRect(x: originX, y: originY, width: imageSize.width, height: imageSize.height))
        arrow.contentMode = .scaleAspectFit
        arrow.image = Assets.image(named: imageName)
        
        return arrow
    }
    
    private func createLabel(coachmarkId: CoachmarkIdentifier, arrowRect: CGRect) -> UILabel {
        
        var originY: CGFloat = 0
        var originX: CGFloat = 0
        var labelWidth: CGFloat?
        var labelHeight: CGFloat?
        let labelPosition = getLabelPosition(coachmarkId: coachmarkId)
        
        let referenceFont = labelFont(coachmarkId: coachmarkId)

        switch labelPosition {
        case .toLeftOfReference:
            if case .toLeftOfReference(let horizontalSeparation, let verticalAdjust, let alignMode) = labelPosition {
                labelWidth = horizontalSeparation >= 0 ? arrowRect.origin.x - minimumMargin - horizontalSeparation : arrowRect.origin.x - minimumMargin
                labelHeight = getLabelHeight(text: texts[coachmarkId] ?? "", width: labelWidth ?? 0, font: referenceFont)
                
                originY = alignMode.getOriginY(referenceElement: arrowRect, elementHeight: labelHeight ?? 0) + verticalAdjust
                originX = horizontalSeparation >= 0 ? minimumMargin : minimumMargin - horizontalSeparation
            }
        case .toRightOfReference:
            if case .toRightOfReference(let horizontalSeparation, let verticalAdjust, let alignMode) = labelPosition {
                labelWidth = horizontalSeparation >= 0 ? (UIScreen.main.bounds.width - minimumMargin) - (arrowRect.origin.x + arrowRect.width) - horizontalSeparation : arrowRect.origin.x + arrowRect.width - horizontalSeparation
                labelHeight = getLabelHeight(text: texts[coachmarkId] ?? "", width: labelWidth ?? 0, font: referenceFont)
                
                originY = alignMode.getOriginY(referenceElement: arrowRect, elementHeight: labelHeight ?? 0) + verticalAdjust
                originX = arrowRect.origin.x + arrowRect.width + horizontalSeparation
            }
        case .underReference:
            if case .underReference(let horizontalAdjust, let verticalSeparation, let alignMode) = labelPosition {
                labelWidth = UIScreen.main.bounds.width - 2*minimumMargin - abs(horizontalAdjust)
                labelHeight = getLabelHeight(text: texts[coachmarkId] ?? "", width: labelWidth ?? 0, font: referenceFont)
                
                originY = arrowRect.origin.y + arrowRect.height + verticalSeparation
                originX = alignMode.getOriginX(referenceElement: arrowRect, elementWidth: labelWidth ?? 0, margin: minimumMargin) + horizontalAdjust
            }
        case .overReference:
            if case .overReference(let horizontalAdjust, let verticalSeparation, let alignMode) = labelPosition {
                labelWidth = UIScreen.main.bounds.width - 2*minimumMargin - abs(horizontalAdjust)
                labelHeight = getLabelHeight(text: texts[coachmarkId] ?? "", width: labelWidth ?? 0, font: referenceFont)

                originY = arrowRect.origin.y - (labelHeight ?? 0) - verticalSeparation
                originX = alignMode.getOriginX(referenceElement: arrowRect, elementWidth: labelWidth ?? 0, margin: minimumMargin) + horizontalAdjust
            }
        case .centeredInScreen:
            if case .centeredInScreen(let verticalSeparation) = labelPosition {
                labelWidth = UIScreen.main.bounds.width - 2*minimumMargin
                labelHeight = getLabelHeight(text: texts[coachmarkId] ?? "", width: labelWidth ?? 0, font: referenceFont)

                originY = arrowRect.origin.y - (labelHeight ?? 0) - verticalSeparation
                originX = minimumMargin
            }
        case .withoutReference: break
        }
        
        let label = UILabel(frame: CGRect(x: originX,
                                      y: originY,
                                      width: labelWidth ?? 0,
                                      height: labelHeight ?? 0))
        label.textAlignment = .center
        label.textColor = .uiWhite
        label.textAlignment = labelAligment(coachmarkId: coachmarkId)
        label.font = labelFont(coachmarkId: coachmarkId)
        label.text = texts[coachmarkId]
        label.numberOfLines = 0
        
        return label
    }
    
    private func labelAligment(coachmarkId: CoachmarkIdentifier) -> NSTextAlignment {
        switch coachmarkId {
        case .transfersHomeSendMoney:
            return .left
        default:
            return .center
        }
    }
    
    private func labelFont(coachmarkId: CoachmarkIdentifier) -> UIFont {
        switch coachmarkId {
        case .transfersHomeSendMoney, .transfersHomeSendToATM, .transfersHomeFavsEmittedAndScheduled:
            return UIFont.handOfSean(size: 15)
        default:
            return UIFont.handOfSean(size: UIScreen.main.isIphone4or5 ? 17 : 20)
        }
    }
    
    private func getImageName(coachmarkId: CoachmarkIdentifier) -> String {
        switch coachmarkId {
        case .pgFinance:
            return "icnArrowPg"
        case .pgAgentChat:
            return "icnArrowChat"
        case .accountsHomeCopyIban:
            return "icnArrowIban"
        case .accountsHomeFilter:
            return "icnArrowAccount"
        case .fundsHomeOperate:
            return "icnArrowFunds"
        case .plansHomeContribute:
            return "icnArrowPlans"
        case .cardsHomeAccessOperatives:
            return "icnArrowCredit"
        case .cardsHomeCheckBalance:
            return "icnArrowEcashCard"
        case .cardsHomeTurnOnOff:
            return "icnArrowDebit"
        case .visualizationOptions:
            return "icnArrowLocation"
        case .clientAttentionPhone:
            return "icnArrowForeignCurrency2"
        case .clientAttentionDate:
            return "icnArrowForeignCurrency"
        case .transfersChooseOption:
            return "icnArrowTransfer"
        case .transfersHomeSendMoney:
            return "icnArrowCoachmarkDown"
        case .transfersHomeSendToATM:
            return "icnArrowCoachmarkUp"
        case .transfersHomeFavsEmittedAndScheduled:
            return "icnArrowCoachmarkCentre"
        case .transfersHomeFavsEmittedAndScheduledLeft:
            return "icnArrowCoachmarkLeft"
        case .transfersHomeFavsEmittedAndScheduledRight:
            return "icnArrowCoachmarkRight"
        case .billAndTaxesMakePayment:
            return "icnArrowBillsPayment"
        case .billAndTaxesManagePayment:
            return "icnArrowBillManagement"
        case .billAndTaxesSearchPayment:
            return "icnArrowBillSearch"
        case .sideMenuManager:
            return ""
        }
    }
    
    private func getLabelPosition(coachmarkId: CoachmarkIdentifier) -> ReferencePosition {
        switch coachmarkId {
        case .pgFinance:
            return ReferencePosition.toLeftOfReference(horizontalSeparation: -8, verticalAdjust: -16, alignMode: .bottomAlign)
        case .pgAgentChat:
            return ReferencePosition.toLeftOfReference(horizontalSeparation: -10, verticalAdjust: 34, alignMode: .topAlign)
        case .accountsHomeCopyIban:
            return ReferencePosition.underReference(horizontalAdjust: 42, verticalSeparation: 0, alignMode: .rightAlign)
        case .accountsHomeFilter:
            return ReferencePosition.toLeftOfReference(horizontalSeparation: -6, verticalAdjust: -30, alignMode: .bottomAlign)
        case .fundsHomeOperate:
            return ReferencePosition.underReference(horizontalAdjust: 20, verticalSeparation: 0, alignMode: .centered)
        case .plansHomeContribute:
            return ReferencePosition.underReference(horizontalAdjust: 20, verticalSeparation: 0, alignMode: .centered)
        case .cardsHomeAccessOperatives:
            return ReferencePosition.underReference(horizontalAdjust: 0, verticalSeparation: 0, alignMode: .centered)     //CREDITO
        case .cardsHomeCheckBalance:
            return ReferencePosition.underReference(horizontalAdjust: 20, verticalSeparation: 0, alignMode: .centered)     //PREPAID
        case .cardsHomeTurnOnOff:
            return ReferencePosition.underReference(horizontalAdjust: 0, verticalSeparation: 0, alignMode: .centered)    //DEBIT
        case .visualizationOptions:
            return ReferencePosition.centeredInScreen(verticalSeparation: -10)
        case .clientAttentionPhone:
            return ReferencePosition.overReference(horizontalAdjust: -10, verticalSeparation: -6, alignMode: .centered)
        case .clientAttentionDate:
            return ReferencePosition.overReference(horizontalAdjust: 0, verticalSeparation: 0, alignMode: .centered)
        case .transfersChooseOption:
            return ReferencePosition.centeredInScreen(verticalSeparation: 30)
        case .transfersHomeSendMoney:
            return .toRightOfReference(horizontalSeparation: 20, verticalAdjust: 30, alignMode: .centered)
        case .transfersHomeSendToATM:
            return .toLeftOfReference(horizontalSeparation: 5, verticalAdjust: 0, alignMode: .centered)
        case .transfersHomeFavsEmittedAndScheduled:
            return .underReference(horizontalAdjust: 0, verticalSeparation: 0, alignMode: .centered)
        case .transfersHomeFavsEmittedAndScheduledLeft:
            return .withoutReference
        case .transfersHomeFavsEmittedAndScheduledRight:
            return .withoutReference
        case .billAndTaxesMakePayment:
            return .toRightOfReference(horizontalSeparation: -2, verticalAdjust: 0, alignMode: .centered)
        case .billAndTaxesManagePayment:
            return .underReference(horizontalAdjust: -12, verticalSeparation: -5, alignMode: .centered)
        case .billAndTaxesSearchPayment:
            return .toLeftOfReference(horizontalSeparation: -10, verticalAdjust: -30, alignMode: .bottomAlign)
        case .sideMenuManager:
            return .withoutReference
        }
    }
    
    private func getArrowPosition(coachmarkId: CoachmarkIdentifier) -> ReferencePosition {
        switch coachmarkId {
        case .pgFinance:
            return ReferencePosition.underReference(horizontalAdjust: 0, verticalSeparation: -2, alignMode: .centered)
        case .pgAgentChat:
            return ReferencePosition.overReference(horizontalAdjust: -14, verticalSeparation: 0, alignMode: .centered)
        case .accountsHomeCopyIban:
            return ReferencePosition.toRightOfReference(horizontalSeparation: -6, verticalAdjust: -16, alignMode: .bottomAlign)
        case .accountsHomeFilter:
            return ReferencePosition.underReference(horizontalAdjust: 10, verticalSeparation: 0, alignMode: .rightAlign)
        case .fundsHomeOperate:
            return ReferencePosition.underReference(horizontalAdjust: 4, verticalSeparation: -30, alignMode: .centered)
        case .plansHomeContribute:
            return ReferencePosition.underReference(horizontalAdjust: 4, verticalSeparation: -30, alignMode: .centered)
        case .cardsHomeAccessOperatives:
            return ReferencePosition.underReference(horizontalAdjust: 24, verticalSeparation: -30, alignMode: .centered)     //CREDITO
        case .cardsHomeCheckBalance:
            return ReferencePosition.underReference(horizontalAdjust: 10, verticalSeparation: 0, alignMode: .centered)     //PREPAID
        case .cardsHomeTurnOnOff:
            return ReferencePosition.underReference(horizontalAdjust: -8, verticalSeparation: -30, alignMode: .centered)     //DEBIT
        case .visualizationOptions:
            return ReferencePosition.toLeftOfReference(horizontalSeparation: 0, verticalAdjust: -26, alignMode: .centered)
        case .clientAttentionPhone:
            return ReferencePosition.overReference(horizontalAdjust: 30, verticalSeparation: -270, alignMode: .centered)
        case .clientAttentionDate:
            return ReferencePosition.overReference(horizontalAdjust: 0, verticalSeparation: 0, alignMode: .centered)
        case .transfersChooseOption:
            return ReferencePosition.underReference(horizontalAdjust: 20, verticalSeparation: 0, alignMode: .centered)
        case .transfersHomeSendMoney:
            return .toLeftOfReference(horizontalSeparation: -95, verticalAdjust: 20, alignMode: .topAlign)
        case .transfersHomeSendToATM:
            return .underReference(horizontalAdjust: -20, verticalSeparation: 10, alignMode: .centered)
        case .transfersHomeFavsEmittedAndScheduled:
            return .underReference(horizontalAdjust: 0, verticalSeparation: 10, alignMode: .centered)
        case .transfersHomeFavsEmittedAndScheduledLeft:
            return .underReference(horizontalAdjust: 0, verticalSeparation: 10, alignMode: .centered)
        case .transfersHomeFavsEmittedAndScheduledRight:
            return .underReference(horizontalAdjust: 0, verticalSeparation: 10, alignMode: .centered)
        case .billAndTaxesMakePayment:
            return .overReference(horizontalAdjust: 10, verticalSeparation: -10, alignMode: .leftAlign)
        case .billAndTaxesManagePayment:
            return .toLeftOfReference(horizontalSeparation: -25, verticalAdjust: 30, alignMode: .centered)
        case .billAndTaxesSearchPayment:
            return .underReference(horizontalAdjust: 10, verticalSeparation: 0, alignMode: .centered)
        case .sideMenuManager:
            return .withoutReference
        }
    }
}
