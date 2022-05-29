import UIKit
import OpenCombine
import CoreFoundationLib
import UI
import CoreDomain

final class PublicMenuViewContainer {
    private let dependencies: PublicMenuDependenciesResolver
    private var anySubscriptions: Set<AnyCancellable> = []
    private let mainStackView = UIStackView()
    let onDidSelectActionSubject = PassthroughSubject<PublicMenuAction, Never>()
    let onDidSelectOfferSubject = PassthroughSubject<OfferRepresentable, Never>()
    let trackEventSubject = PassthroughSubject<String, Never>()
    let smallCellDefaultHeight: CGFloat = 53.0
    let smallCellDoubleLineHeight: CGFloat = 60.0
    let atmCellHeight: CGFloat = 80.0
    let defaultHeight: CGFloat = 128.0
    let publicOffersHeight: CGFloat = 103.0
    
    init(dependencies: PublicMenuDependenciesResolver) {
        self.dependencies = dependencies
    }
    
    func composeView(data: [[PublicMenuElementRepresentable]]) -> UIView {
        self.cleanStackView()
        self.configureStackView()
        for rowData in data {
            let rowView = composeRowView(dataRow: rowData)
            self.mainStackView.addArrangedSubview(rowView)
        }
        return self.mainStackView
    }
}

private extension PublicMenuViewContainer {

    func cleanStackView() {
        self.mainStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func configureStackView() {
        self.mainStackView.translatesAutoresizingMaskIntoConstraints = false
        self.mainStackView.axis = .vertical
        self.mainStackView.spacing = 8
        self.mainStackView.distribution = .fill
    }
    
    func composeRowView(dataRow: [PublicMenuElementRepresentable]) -> UIView {
        let stackViewRow = UIStackView()
        stackViewRow.translatesAutoresizingMaskIntoConstraints = false
        stackViewRow.axis = .horizontal
        stackViewRow.spacing = dataRow.count > 1 ? 8 : 0
        stackViewRow.distribution = dataRow.count > 1 ? .fillEqually : .fill
        for colData in dataRow {
            let colView = composeRowColView(dataCol: colData)
            stackViewRow.addArrangedSubview(colView)
        }
        return stackViewRow
    }
    
    func composeRowColView(dataCol: PublicMenuElementRepresentable) -> UIView {
        let dataColTop = dataCol.top
        let dataColBottom = dataCol.bottom
        let stackViewCell = UIStackView()
        stackViewCell.translatesAutoresizingMaskIntoConstraints = false
        stackViewCell.axis = .vertical
        stackViewCell.spacing = 8
        stackViewCell.distribution = (dataColTop != nil) && (dataColBottom != nil) ? .fillEqually : .fill
        if let itemTop = dataColTop {
            let viewTop = composeItem(item: itemTop)
            stackViewCell.addArrangedSubview(viewTop)
        }
        if let itemBottom = dataColBottom {
            let viewBottom = composeItem(item: itemBottom)
            stackViewCell.addArrangedSubview(viewBottom)
        }
        return stackViewCell
    }
    
    func composeItem(item: PublicMenuOptionRepresentable) -> UIView {
        var view = UIView()
        switch item.type {
        case .smallButton(style: let style):
            view = makeSmallButtonView(item, buttonType: style)
        case .bigButton(style: let style):
            view = makeBigButtonView(item, buttonType: style)
        case .bigCallButton:
            view = makeBigCallButtonView(item)
        case .atm(bgImage: let bgImage):
            view = makeATMView(item, bgImage: bgImage)
        case .phonesButton(top: let topPhone, bottom: let bottomPhone):
            view = makePhonesButtonView(item, topPhone: topPhone, bottomPhone: bottomPhone)
        case .selectOptionButton(options: let options):
            view = makeSelectOptionButtonView(item, options: options)
        case .flipButton(principalItem: let principal, secondaryItem: let secondary, let time):
            view = makeFlipView(principal, secondary, time: time)
        case .callNow(phone: let phone):
            view = makeCallNowButtonView(item, phone: phone)
        case .publicOffer(items: let items):
            view = makePullOfferView(item, info: items)
        }
        let viewHeight = self.getViewHeight(item: item)
        view.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        return view
    }
    
    func getViewHeight(item: PublicMenuOptionRepresentable) -> CGFloat {
        switch item.type {
        case .smallButton:
            if item.kindOfNode == KindOfPublicMenuNode.prepaidLogin ||
                item.kindOfNode == KindOfPublicMenuNode.recoverPassword ||
                item.kindOfNode == KindOfPublicMenuNode.getMagic {
                return self.smallCellDoubleLineHeight
            }
            return self.smallCellDefaultHeight
        case .atm:
            return self.atmCellHeight
        case .publicOffer:
            return self.publicOffersHeight
        default: return self.defaultHeight
        }
    }
    
    func makeSmallButtonView(_ model: PublicMenuOptionRepresentable, buttonType: SmallButtonTypeRepresentable) -> SmallButtonView {
        let view = SmallButtonView()
        view.configure(withModel: model, buttonType: buttonType)
        view.onTouchButtonSubject
            .sink { [unowned self] model in
                self.onDidSelectActionSubject.send(model.action)
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        
        return view
    }
    
    func makeBigButtonView(_ model: PublicMenuOptionRepresentable, buttonType: BigButtonTypeRepresentable) -> BigButtonView {
        let view = BigButtonView()
        view.configure(withModel: model, buttonType: buttonType)
        view.onTouchButtonSubject
            .sink { [unowned self] model in
                self.onDidSelectActionSubject.send(model.action)
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        return view
    }
    
    func makeATMView(_ model: PublicMenuOptionRepresentable, bgImage: String?) -> ATMView {
        let view = ATMView()
        view.configure(withModel: model, bgImage: bgImage)
        view.onTouchButtonSubject
            .sink { [unowned self] model in
                self.onDidSelectActionSubject.send(model.action)
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        return view
    }
    
    func makeBigCallButtonView(_ model: PublicMenuOptionRepresentable) -> BigCallButtonView {
        let view = BigCallButtonView()
        view.configure(withModel: model)
        view.onTouchButtonSubject
            .sink { [unowned self] model in
                self.onDidSelectActionSubject.send(model.action)
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        return view
    }
    
    func makeSelectOptionButtonView(_ model: PublicMenuOptionRepresentable, options: [SelectOptionButtonModelRepresentable]) -> SelectOptionButtonView {
        let view = SelectOptionButtonView()
        view.configure(withModel: model, options: options)
        view.onTouchButtonSubject
            .sink { [unowned self] action in
                self.onDidSelectActionSubject.send(action)
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        return view
    }
    
    func makePhonesButtonView(_ model: PublicMenuOptionRepresentable, topPhone: String, bottomPhone: String ) -> DoublePhoneSelectView {
        let view = DoublePhoneSelectView()
        view.configure(withModel: model, topPhone: topPhone, bottomPhone: bottomPhone)
        view.onTouchButtonSubject
            .sink { [unowned self] phone in
                self.onDidSelectActionSubject.send(.callPhone(number: phone))
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        return view
    }
    
    func makeCallNowButtonView(_ model: PublicMenuOptionRepresentable, phone: String) -> CallNowButtonView {
        let view = CallNowButtonView()
        view.configure(withModel: model, phone: phone)
        view.onTouchButtonSubject
            .sink { [unowned self] (model, _) in
                self.onDidSelectActionSubject.send(model.action)
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        return view
    }
    
    func makeFlipView(_ principal: PublicMenuOptionRepresentable, _ secondary: PublicMenuOptionRepresentable, time: Double) -> UIView {
        let principalView = composeItem(item: principal)
        let secondaryView = composeItem(item: secondary)
        let flipView = FlipBackButtonView()
        flipView.configure(principalView: principalView, secondaryView: secondaryView, time: time)
        return flipView
    }
    
    func makePullOfferView(_ model: PublicMenuOptionRepresentable, info: [PublicOfferElementRepresentable]) -> UIView {
        let view = PublicOffersCarrousel(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.configure(publicMenuOption: model, publicOfferElems: info)
        view.state
            .case { PublicOffersCarrouselState.didSelectOffer }
            .sink { [unowned self] offer in
                self.onDidSelectOfferSubject.send(offer)
                self.trackEventSubject.send(model.event)
            }.store(in: &anySubscriptions)
        view.state
            .case { PublicOffersCarrouselState.scrollViewDidEndDecelerating }
            .filter { isActive in
                return isActive == true
            }
            .sink { [unowned self] _ in
                self.trackEventSubject.send(PublicMenuPage.Action.swipe.rawValue)
            }.store(in: &anySubscriptions)
        return view
    }
}
