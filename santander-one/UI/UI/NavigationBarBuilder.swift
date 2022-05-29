//
//  UIViewController+navigationBuilder.swift
//  UI
//
//  Created by Cristobal Ramos Laina on 30/03/2020.
//

import UIKit
import CoreFoundationLib
import CoreDomain

public class NavigationBarBuilder {
    public typealias TooltipAction = (_ sender: UIView) -> Void
    public typealias Action = () -> Void
    
    public enum ToolTipType {
        case white
        case red
    }
    public enum Title {
        case none
        case title(key: String, identifier: String? = nil)
        case titleWithImage(key: String, image: TitleImage)
        case tooltip(titleKey: String, type: ToolTipType, identifier: String? = nil, action: TooltipAction)
        case titleWithHeader(titleKey: String, header: Header)
        case titleWithHeaderAndImage(titleKey: String, header: Header, image: TitleImage)
    }
    public enum Header {
        case title(key: String, style: HeaderStyle)
    }
    public enum Background {
        case clear
        case color(UIColor)
    }
    public enum Style {
        case white
        case sky
        case clear(tintColor: UIColor)
        case custom(background: Background, tintColor: UIColor)
    }
    public enum HeaderStyle {
        case `default`
        
        func textColor() -> UIColor {
            switch self {
            case .default:
                return UIColor.mediumSanGray
            }
        }
        
        func font() -> UIFont {
            switch self {
            case .default:
                return .santander(family: .text, type: .regular, size: 10.0)
            }
        }
    }
    public enum LeftAction {
        case none
        case back(action: NavigationBarAction)
        case image(image: String, action: NavigationBarAction)
        
        @available(*, deprecated, message: "Use the .back(action: NavigationBarAction) instead")
        public static func back(action: Selector) -> LeftAction {
            return .back(action: .selector(action))
        }
        
        @available(*, deprecated, message: "Use the .image(image: String, action: NavigationBarAction) instead")
        public static func image(image: String, action: Selector) -> LeftAction {
            return .image(image: image, action: .selector(action))
        }
    }
    
    public enum RightAction: UniqueIdentifiable {
        case close(action: NavigationBarAction)
        case menu(action: NavigationBarAction)
        case mail(action: NavigationBarAction)
        case title(title: String, action: NavigationBarAction, font: UIFont?, accessibilityIdentifier: String?)
        case image(image: String, action: NavigationBarAction)
        case help(action: NavigationBarAction)
        case imageAndText(image: String, text: String, action: NavigationBarAction, template: Bool)
        
        @available(*, deprecated, message: "Use the .close(action: NavigationBarAction) instead")
        public static func close(action: Selector) -> RightAction {
            return .close(action: .selector(action))
        }
        @available(*, deprecated, message: "Use the .menu(action: NavigationBarAction) instead")
        public static func menu(action: Selector) -> RightAction {
            return .menu(action: .selector(action))
        }
        @available(*, deprecated, message: "Use the .mail(action: NavigationBarAction) instead")
        public static func mail(action: Selector) -> RightAction {
            return .mail(action: .selector(action))
        }
        @available(*, deprecated, message: "Use the .title(title: String, action: NavigationBarAction, font: UIFont?, accessibilityIdentifier: String?) instead")
        public static func title(title: String, action: Selector, font: UIFont?, accessibilityIdentifier: String?) -> RightAction {
            return .title(title: title, action: .selector(action), font: font, accessibilityIdentifier: accessibilityIdentifier)
        }
        @available(*, deprecated, message: "Use the .image(image: String, action: NavigationBarAction) instead")
        public static func image(image: String, action: Selector) -> RightAction {
            return .image(image: image, action: .selector(action))
        }
        @available(*, deprecated, message: "Use the .help(action: NavigationBarAction) instead")
        public static func help(action: Selector) -> RightAction {
            return .help(action: .selector(action))
        }
        @available(*, deprecated, message: "Use the .imageAndText(image: String, text: String, action: NavigationBarAction, template: Bool) instead")
        public static func imageAndText(image: String, text: String, action: Selector, template: Bool) -> RightAction {
            return .imageAndText(image: image, text: text, action: .selector(action), template: template)
        }
        
        public var uniqueIdentifier: Int {
            var hasher = Hasher()
            switch self {
            case .close:
                hasher.combine("close")
            case .menu:
                hasher.combine("menu")
            case .mail:
                hasher.combine("mail")
            case .title:
                hasher.combine("title")
            case .image(image: let image, _):
                hasher.combine("image:\(image)")
            case .help:
                hasher.combine("help")
            case .imageAndText(image: let image, _, _, _):
                hasher.combine("imageAndText:\(image)")
            }
            return hasher.finalize()
        }
    }
    
    private class Setup {
        var tintColor: UIColor = .clear
        var background: Background = .clear
        var title: Title = .none
        var header: Header?
        var leftAction: LeftAction = .none
        var rightActions: [RightAction] = []
        var headerTextColor: UIColor?
        var headerFont: UIFont?
        
        init() {}
        
        init(style: Style, title: Title) {
            self.title = title
            switch style {
            case .clear(let tintColor):
                self.tintColor = tintColor
                self.background = .clear
            case .white:
                self.tintColor = .santanderRed
                self.background = .color(.white)
            case .sky:
                self.tintColor = .santanderRed
                self.background = .color(.skyGray)
            case .custom(let background, let tintColor):
                self.tintColor = tintColor
                self.background = background
            }
        }
    }
    
    private let setup: Setup
    
    public init(style: Style, title: Title) {
        self.setup = Setup(style: style, title: title)
    }
    
    @discardableResult
    public func setLeftAction(_ action: LeftAction) -> Self {
        self.setup.leftAction = action
        return self
    }
    
    @discardableResult
    public func setRightActions(_ actions: RightAction...) -> Self {
        self.setup.rightActions = actions
        return self
    }
    
    @discardableResult
    public func setRightActions(_ actions: [RightAction]) -> Self {
        self.setup.rightActions = actions
        return self
    }
    
    public func build(on viewController: UIViewController, with presenter: MenuTextGetProtocol?) {
        if let presenterUnwrapped = presenter {
            presenterUnwrapped.get { configuration in
                self.build(on: viewController, with: configuration)
            }
        } else {
            self.build(on: viewController, with: [:])
        }
    }
    
    public func build(on viewController: UIViewController, with configuration: [MenuTextModel: String]) {
        self.reset(on: viewController)
        viewController.setBackground(self.setup.background, tintColor: self.setup.tintColor)
        viewController.setLeftAction(self.setup.leftAction, tintColor: self.setup.tintColor)
        viewController.setRightActions(self.setup.rightActions, tintColor: self.setup.tintColor, configuration: configuration)
        let leftItemsWidth: CGFloat = 90
        let rightItemsWidth: CGFloat = CGFloat(self.setup.rightActions.count * 44) + CGFloat(self.setup.rightActions.count * 6)
        let availableWidth = (viewController.navigationController?.navigationBar.bounds.width ?? 0) - leftItemsWidth - rightItemsWidth
        viewController.setTitle(self.setup.title, tintColor: self.setup.tintColor, maxWidth: availableWidth)
        viewController.redrawNavigationBar()
    }
    
    public func addSearch(on viewController: UIViewController, searchPosition: Int, configuration: [MenuTextModel: String], action: NavigationBarAction) {
        guard let searchVC = viewController as? (UIViewController & NavigationBarWithSearch) else { return }
        let searchTitle = configuration[MenuTextModel.search]
        searchVC.addSearch(tintColor: self.setup.tintColor, searchText: searchTitle, position: searchPosition, action: action)
    }
    
    @available(*, deprecated, message: "Use the addSearch(on viewController: UIViewController, searchPosition: Int, configuration: [MenuTextModel: String], action: NavigationBarAction) instead")
    public func addSearch(on viewController: UIViewController, searchPosition: Int, configuration: [MenuTextModel: String], selector: Selector) {
        guard let searchVC = viewController as? (UIViewController & NavigationBarWithSearch) else { return }
        let searchTitle = configuration[MenuTextModel.search]
        searchVC.addSearch(tintColor: self.setup.tintColor, searchText: searchTitle, position: searchPosition, action: .selector(selector))
    }
    
    private func reset(on viewController: UIViewController) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        viewController.navigationController?.navigationBar.isTranslucent = false
        viewController.navigationItem.setHidesBackButton(true, animated: false)
        viewController.navigationController?.navigationBar.barStyle = .black
        viewController.navigationController?.navigationBar.shadowImage = nil
        viewController.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
}

public struct TitleImage {
    let image: UIImage?
    let topMargin: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    public init(image: UIImage?, topMargin: CGFloat, width: CGFloat, height: CGFloat) {
        self.image = image
        self.width = width
        self.height = height
        self.topMargin = topMargin
    }
}

public extension UIViewController {
    
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

private extension UIViewController {
    
    func resetNavigationController() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.barStyle = .default
    }
    
    func setLeftAction(_ action: NavigationBarBuilder.LeftAction, tintColor: UIColor) {
        switch action {
        case .back(let action):
            let info = AccessibilityInfo(
                accessibilityIdentifier: "icnArrowLeftRed",
                accessibilityLabel: localized("siri_voiceover_back")
            )
            self.setLeftAction(withImage: "oneIcnBack", action: action, tintColor: tintColor, accessibilityInfo: info)
        case .image(let image, let action):
            let info = AccessibilityInfo(accessibilityIdentifier: image)
            self.setLeftAction(withImage: image, action: action, tintColor: tintColor, accessibilityInfo: info)
        case .none:
            break
        }
    }
    
    func setLeftAction(withImage image: String, action: NavigationBarAction, tintColor: UIColor, accessibilityInfo: AccessibilityInfo) {
        let info = AccessibilityInfo(accessibilityIdentifier: image)
        self.navigationItem.leftBarButtonItem = self.newBarButton(withImage: image, action: action, tintColor: tintColor, accessibilityInfo: info)
        self.navigationItem.leftBarButtonItem?.accessibilityIdentifier = accessibilityInfo.accessibilityIdentifier
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = accessibilityInfo.accessibilityLabel
        self.navigationItem.leftBarButtonItem?.accessibilityValue = accessibilityInfo.accessibilityValue
        self.navigationItem.leftBarButtonItem?.accessibilityHint = accessibilityInfo.accessibilityHint
    }
    
    func setRightActions(_ actions: [NavigationBarBuilder.RightAction], tintColor: UIColor, configuration: [MenuTextModel: String]) {
        guard actions.count > 0 else { return }
        self.navigationItem.rightBarButtonItems = []
        actions.forEach { action in
            switch action {
            case .menu(let action):
                let info = AccessibilityInfo(accessibilityIdentifier: AccessibilityNavigation.icnMenu.rawValue,
                                             accessibilityLabel: localized("generic_label_menu"))
                if let titleText = configuration[MenuTextModel.menu] {
                    self.addRightAction(withImage: "icnMenu", text: titleText, template: true, action: action, tintColor: tintColor, accessibilityInfo: info)
                } else {
                    self.addRightAction(withImage: "icnMenu", action: action, tintColor: tintColor, accessibilityInfo: info)
                }
            case .close(let action):
                let info = AccessibilityInfo(
                    accessibilityIdentifier: AccessibilityNavigation.icnClose.rawValue,
                    accessibilityLabel: localized("siri_voiceover_close")
                )
                self.addRightAction(withImage: "icnClose", action: action, tintColor: tintColor, accessibilityInfo: info)
            case .title(let title, let action, let font, let accessibilityIdentifier):
                let info = AccessibilityInfo(accessibilityIdentifier: accessibilityIdentifier)
                self.addRightAction(withTitle: title, action: action, tintColor: tintColor, accessibilityInfo: info, font: font)
            case .image(image: let image, action: let action):
                self.addRightAction(withImage: image, action: action, tintColor: tintColor)
            case .imageAndText(let image, let text, let action, let template):
                self.addRightAction(withImage: image, text: text, template: template, action: action, tintColor: tintColor)
            case .mail(let action):
                let info = AccessibilityInfo(accessibilityIdentifier: AccessibilityNavigation.icnMail.rawValue,
                                             accessibilityLabel: localized("generic_label_mailbox"))
                if let titleText = configuration[MenuTextModel.mailBox] {
                    self.addRightAction(withImage: "icnMailRed", text: titleText, template: true, action: action, tintColor: tintColor, accessibilityInfo: info)
                } else {
                    self.addRightAction(withImage: "icnMailRed", action: action, tintColor: tintColor, accessibilityInfo: info)
                }
            case .help(let action):
                let info = AccessibilityInfo(accessibilityIdentifier: AccessibilityNavigation.icnQuestion.rawValue)
                self.addRightAction(withImage: "icnQuestion", text: localized("generic_label_help").text, template: false, action: action, tintColor: tintColor, accessibilityInfo: info)
            }
            guard let searchVC = self as? (UIViewController & NavigationBarWithSearchProtocol), searchVC.isSearchEnabled else { return }
            let searchTitle = configuration[MenuTextModel.search]
            searchVC.addSearch(tintColor: tintColor, searchText: searchTitle)
        }
    }
    
    func addRightAction(withImage image: String, action: NavigationBarAction, tintColor: UIColor, accessibilityInfo: AccessibilityInfo = AccessibilityInfo()) {
        self.navigationItem.rightBarButtonItems?.append(self.newBarButton(withImage: image, action: action, tintColor: tintColor, accessibilityInfo: accessibilityInfo))
    }
    
    func addRightAction(withImage image: String, text: String, template: Bool, action: NavigationBarAction, tintColor: UIColor, accessibilityInfo: AccessibilityInfo = AccessibilityInfo()) {
        self.navigationItem.rightBarButtonItems?.append(self.newBarButton(withImage: image, text: text, template: template, action: action, tintColor: tintColor, accessibilityInfo: accessibilityInfo))
    }
    
    func addRightAction(withTitle title: String, action: NavigationBarAction, tintColor: UIColor, accessibilityInfo: AccessibilityInfo = AccessibilityInfo(), font: UIFont?) {
        self.navigationItem.rightBarButtonItems?.append(self.newBarButton(withTitle: title, action: action, tintColor: tintColor, accessibilityInfo: accessibilityInfo, font: font))
    }
    
    func newBarButton(withTitle title: String, action: NavigationBarAction, tintColor: UIColor, accessibilityInfo: AccessibilityInfo, font: UIFont?) -> UIBarButtonItem {
        let barButton: UIBarButtonItem
        switch action {
        case .selector(let selector):
            barButton = UIBarButtonItem(
                title: title,
                style: .plain,
                target: self,
                action: selector
            )
        case .closure(let action):
            barButton = UIBarButtonItem(
                title: title,
                style: .plain,
                action: action
            )
        }
        barButton.accessibilityIdentifier = accessibilityInfo.accessibilityIdentifier
        barButton.accessibilityIdentifier = accessibilityInfo.accessibilityIdentifier
        barButton.accessibilityLabel = accessibilityInfo.accessibilityLabel
        barButton.accessibilityValue = accessibilityInfo.accessibilityValue
        barButton.accessibilityHint = accessibilityInfo.accessibilityHint
        barButton.tintColor = tintColor
        if let font = font {
            barButton.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: tintColor,
                NSAttributedString.Key.font: font
            ], for: UIControl.State.normal)
            barButton.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: tintColor,
                NSAttributedString.Key.font: font
            ], for: UIControl.State.highlighted)
        }
        return barButton
    }
    
    func newBarButton(withImage image: String, text: String, template: Bool, action: NavigationBarAction, tintColor: UIColor, accessibilityInfo: AccessibilityInfo) -> UIBarButtonItem {
        let button = ImageAndTextButton()
        switch action {
        case .selector(let selector):
            button.set(title: text, image: image, target: self, action: selector, tintColor: tintColor, template: template)
        case .closure(let action):
            button.set(title: text, image: image, action: action, tintColor: tintColor, template: template)
        }
        button.sizeToFit()
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.tintColor = UIColor.clear
        barButtonItem.accessibilityIdentifier = accessibilityInfo.accessibilityIdentifier
        barButtonItem.accessibilityLabel = accessibilityInfo.accessibilityLabel
        barButtonItem.accessibilityValue = accessibilityInfo.accessibilityValue
        barButtonItem.accessibilityHint = accessibilityInfo.accessibilityHint
        return barButtonItem
    }
    
    func newBarButton(withImage image: String, action: NavigationBarAction, tintColor: UIColor, accessibilityInfo: AccessibilityInfo) -> UIBarButtonItem {
        let barButton: UIBarButtonItem
        switch action {
        case .selector(let selector):
            barButton = UIBarButtonItem(
                image: Assets.image(named: image)?.withRenderingMode(.alwaysTemplate),
                style: .plain,
                target: self,
                action: selector
            )
        case .closure(let action):
            barButton = UIBarButtonItem(
               image: Assets.image(named: image)?.withRenderingMode(.alwaysTemplate),
               style: .plain,
               action: action
           )
        }
        barButton.accessibilityIdentifier = accessibilityInfo.accessibilityIdentifier
        barButton.accessibilityLabel = accessibilityInfo.accessibilityLabel
        barButton.accessibilityValue = accessibilityInfo.accessibilityValue
        barButton.accessibilityHint = accessibilityInfo.accessibilityHint
        barButton.tintColor = tintColor
        return barButton
    }
    
    func setBackground(_ background: NavigationBarBuilder.Background, tintColor: UIColor) {
        switch background {
        case .color(let color):
            if #available(iOS 11, *) {
                self.setAppearanceToIOS11(backgroundColor: color, tintColor: tintColor)
            } else {
                self.setAppearanceToIOS10(backgroundColor: color)
            }
        case .clear:
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.navigationBar.tintColor = tintColor
            self.navigationController?.navigationBar.barTintColor = .clear
            self.navigationController?.navigationBar.backgroundColor = .clear
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setNavigationBarColor(.clear)
        }
    }
    
    func setAppearanceToIOS11(backgroundColor: UIColor, tintColor: UIColor) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.setNavigationBarColor(backgroundColor)
        self.addShadow()
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    func setAppearanceToIOS10(backgroundColor: UIColor) {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = backgroundColor
        self.navigationController?.navigationBar.setNavigationBarColor(backgroundColor)
        self.navigationController?.navigationBar.barStyle = .black
        self.addShadow()
        self.redrawNavigationBar()
    }
    
    func redrawNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setTitle(_ title: NavigationBarBuilder.Title, tintColor: UIColor, maxWidth: CGFloat) {
        switch title {
        case .tooltip(let title, let toolTipType, let identifier, let tooltipAction):
            let tooltipButton = getTooltipButton(title: title, tintColor: tintColor, tooltipAction, toolTipType, maxWidth: maxWidth)
            tooltipButton.accessibilityLabel = localized(title) + localized("generic_label_moreInfo")
            if let identifier = identifier {
                tooltipButton.accessibilityIdentifier = identifier
                tooltipButton.titleLabel?.accessibilityIdentifier = identifier + "_label"
                tooltipButton.imageView?.accessibilityIdentifier = identifier + "_image"
            } else {
                tooltipButton.accessibilityIdentifier = title + "_Container"
            }
            self.navigationItem.titleView = tooltipButton
        case .title(key: let title, identifier: let identifier):
            setSimpleTitle(title, identifier: identifier, tintColor: tintColor)
        case .none:
            break
        case .titleWithHeader(let titleKey, let header):
            switch header {
            case .title(let key, let hstyle):
                setTitle(titleKey, tintColor: tintColor, andHeader: key, headerTextColor: hstyle.textColor(), headerFont: hstyle.font())
            }
        case .titleWithImage(let key, let image):
            self.setTitle(key, image: image, tintColor: tintColor)
        case .titleWithHeaderAndImage(let titleKey, let header, let image):
            switch header {
            case .title(let key, let hstyle):
                setTitle(titleKey, tintColor: tintColor, andHeader: key, headerTextColor: hstyle.textColor(), headerFont: hstyle.font(), image: image)
            }
        }
    }
    
    func getTooltipButton(title: String, tintColor: UIColor,
                          _ action: @escaping NavigationBarBuilder.TooltipAction,
                          _ type: NavigationBarBuilder.ToolTipType,
                          maxWidth: CGFloat? = nil) -> UIButton {
        let button = ToolTipButton()
        button.setTitle(localized(title), for: .normal)
        button.setTitleColor(tintColor, for: .normal)
        button.setupBg(type: type, maxWidth: maxWidth, action: action)
        button.titleLabel?.accessibilityIdentifier = title
        return button
    }
    
    func addShadow() {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(rect)
        }
        self.navigationController?.navigationBar.shadowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}

public enum NavigationBarAction {
    case selector(Selector)
    case closure(() -> Void)
}

// MARK: - Title methods

private extension UIViewController {
    func setSimpleTitle(_ title: String, identifier: String? = nil, tintColor: UIColor) {
        if #available(iOS 11.0, *) {
            let headerTitleBtn = ToolTipButton()
            headerTitleBtn.setTitle(localized(title), for: .normal)
            headerTitleBtn.titleLabel?.font = UIFont.santander(family: .headline, type: .bold, size: 18.0)
            headerTitleBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            headerTitleBtn.setTitleColor(tintColor, for: .normal)
            if let identifier = identifier {
                headerTitleBtn.titleLabel?.accessibilityIdentifier = identifier
            } else {
                headerTitleBtn.titleLabel?.accessibilityIdentifier = title
            }
            headerTitleBtn.accessibilityTraits = .staticText
            self.navigationItem.titleView = headerTitleBtn
        } else {
            self.setTitleToIOS10(title, tintColor: tintColor)
        }
    }
    
    func setTitleToIOS10(_ title: String, tintColor: UIColor) {
        let font = UIFont.santander(family: .headline, type: .bold, size: 16.0)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: tintColor
        ]
        self.navigationItem.title = localized(title)
        self.navigationController?.navigationBar.titleTextAttributes = attributes
    }
    
    func setTitle(_ title: String, image: TitleImage, tintColor: UIColor) {
        self.navigationItem.title = nil // BaseViewController set this value
        let titleFont = UIFont.santander(family: .headline, type: .bold, size: 18.0)
        let titleView: UIStackView
        if #available(iOS 11.0, *) {
            titleView = UIStackView()
        } else {
            let titleTextSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont])
            titleView = UIStackView(frame: CGRect(x: 0, y: 0, width: titleTextSize.width, height: 44))
            titleView.alignment = .center
        }
        titleView.axis = .horizontal
        let containerImageView = UIView()
        let imageView = UIImageView(image: image.image)
        containerImageView.addSubview(imageView)
        imageView.fullFit(topMargin: image.topMargin, bottomMargin: 0, leftMargin: 0, rightMargin: 0)
        imageView.heightAnchor.constraint(equalToConstant: image.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: image.width).isActive = true
        let middleSpaceView = UIView()
        middleSpaceView.widthAnchor.constraint(equalToConstant: 3).isActive = true
        let titleBtn = ToolTipButton()
        titleBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleBtn.setTitle(localized(title), for: .normal)
        titleBtn.titleLabel?.accessibilityIdentifier = title
        titleBtn.titleLabel?.font = titleFont
        titleBtn.setTitleColor(tintColor, for: .normal)
        titleView.addArrangedSubview(containerImageView)
        titleView.addArrangedSubview(middleSpaceView)
        titleView.addArrangedSubview(titleBtn)
        titleView.accessibilityLabel = localized(title)
        titleView.accessibilityTraits = .none
        self.navigationItem.titleView = titleView
    }
    
    func setTitle(_ title: String, tintColor: UIColor, andHeader header: String, headerTextColor: UIColor, headerFont: UIFont) {
        self.navigationItem.title = nil // BaseViewController set this value
        let titleFont = UIFont.santander(family: .headline, type: .bold, size: 18.0)
        let titleTextSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont])
        var titleView: UIStackView
        
        if #available(iOS 11.0, *) {
            titleView = UIStackView()
        } else {
            titleView = UIStackView(frame: CGRect(x: 0, y: 0, width: titleTextSize.width, height: 44))
        }
        titleView.alignment = .center
        titleView.distribution = .fillProportionally
        titleView.axis = .vertical
        titleView.accessibilityLabel = localized(title)
        titleView.accessibilityTraits = .none
        
        let headerLabel = UILabel()
        headerLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        headerLabel.font = headerFont
        headerLabel.textColor = headerTextColor
        headerLabel.text = localized(header).uppercased()
        headerLabel.accessibilityIdentifier = "navBarHeaderTitle"
        
        let titleBtn = ToolTipButton()
        titleBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleBtn.setTitle(localized(title), for: .normal)
        titleBtn.accessibilityIdentifier = "toolbar_titleBottom_tips"
        titleBtn.titleLabel?.font = titleFont
        titleBtn.setTitleColor(tintColor, for: .normal)
        titleBtn.accessibilityIdentifier = "navBarTitle"
        
        let middleSpaceView = UIView()
        middleSpaceView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        let bottomSpaceView = UIView()
        bottomSpaceView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        titleView.addArrangedSubview(headerLabel)
        titleView.addArrangedSubview(middleSpaceView)
        titleView.addArrangedSubview(titleBtn)
        titleView.addArrangedSubview(bottomSpaceView)
        self.navigationItem.titleView = titleView
    }
    
    func setTitle(_ title: String,
                  tintColor: UIColor,
                  andHeader header: String,
                  headerTextColor: UIColor,
                  headerFont: UIFont,
                  image: TitleImage) {
        self.navigationItem.title = nil // BaseViewController set this value
        let titleFont = UIFont.santander(family: .headline, type: .bold, size: 18.0)
        var titleView: UIStackView
        var titleAndImage: UIStackView
        if #available(iOS 11.0, *) {
            titleView = UIStackView()
            titleAndImage = UIStackView()
        } else {
            let titleTextSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont])
            titleView = UIStackView(frame: CGRect(x: 0, y: 0, width: titleTextSize.width + image.width + 3, height: 44))
            titleAndImage = UIStackView(frame: CGRect(x: 0.0, y: 0.0, width: image.width + 3 + titleTextSize.width, height: max(image.height, titleTextSize.height)))
        }
        titleView.alignment = .center
        titleView.distribution = .fillProportionally
        titleView.axis = .vertical
        titleView.accessibilityLabel = localized(title)
        titleView.accessibilityTraits = .none
        titleAndImage.axis = .horizontal
        let containerImageView = UIView()
        let imageView = UIImageView(image: image.image)
        containerImageView.addSubview(imageView)
        imageView.fullFit(topMargin: image.topMargin, bottomMargin: 0, leftMargin: 0, rightMargin: 0)
        imageView.heightAnchor.constraint(equalToConstant: image.height).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: image.width).isActive = true
        let headerLabel = UILabel()
        headerLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        headerLabel.font = headerFont
        headerLabel.textColor = headerTextColor
        headerLabel.text = localized(header).uppercased()
        headerLabel.accessibilityIdentifier = header
        let titleBtn = ToolTipButton()
        titleBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        titleBtn.setTitle(localized(title), for: .normal)
        titleBtn.titleLabel?.accessibilityIdentifier = title
        titleBtn.titleLabel?.font = titleFont
        titleBtn.setTitleColor(tintColor, for: .normal)
        let middleImageSpaceView = UIView()
        middleImageSpaceView.widthAnchor.constraint(equalToConstant: 3).isActive = true
        let bottomSpaceView = UIView()
        bottomSpaceView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        titleAndImage.addArrangedSubview(containerImageView)
        titleAndImage.addArrangedSubview(middleImageSpaceView)
        titleAndImage.addArrangedSubview(titleBtn)
        let middleSpaceView = UIView()
        middleSpaceView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        titleView.addArrangedSubview(headerLabel)
        titleView.addArrangedSubview(middleSpaceView)
        titleView.addArrangedSubview(titleAndImage)
        titleView.addArrangedSubview(bottomSpaceView)
        self.navigationItem.titleView = titleView
    }
}

public extension UINavigationBar {
    func setNavigationBarColor(_ color: UIColor) {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = color
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
            compactAppearance = appearance
        } else {
            barTintColor = color
        }
    }
}

extension UIBarButtonItem {
    
    convenience init(image: UIImage?, style: UIBarButtonItem.Style, action: @escaping () -> Void) {
        self.init(image: image, style: style, target: nil, action: nil)
        onTap(action: action)
    }
    
    convenience init(title: String?, style: UIBarButtonItem.Style, action: @escaping () -> Void) {
        self.init(title: title, style: style, target: nil, action: nil)
        onTap(action: action)
    }
    
    convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, action: @escaping () -> Void) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: nil)
        onTap(action: action)
    }
    
    func onTap(action: @escaping () -> Void) {
        self.target = self
        self.action = #selector(UIBarButtonItem.buttonTapped)
        NotificationCenter.default.addObserver(forName: .barButtonItemTapped, object: self, queue: OperationQueue.main) { _ in
            action()
        }
    }
}

fileprivate extension UIBarButtonItem {
    @objc func buttonTapped() {
        NotificationCenter.default.post(name: .barButtonItemTapped, object: self)
    }
}

fileprivate extension Notification.Name {
    static let barButtonItemTapped = Notification.Name("UIBarButtonItem.tapped")
}
