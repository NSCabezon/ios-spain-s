import UI
import CoreFoundationLib

protocol BizumSendAgainViewProtocol: class {
    func setSendAgainView(_ items: [BizumSendAgainViewModel])
}

final class BizumSendAgainView: SheetView {
    private let presenter: BizumSendAgainPresenterProtocol

    init(presenter: BizumSendAgainPresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func load() {
        self.presenter.viewDidLoad()
    }
}

extension BizumSendAgainView: BizumSendAgainViewProtocol {
    func setSendAgainView(_ items: [BizumSendAgainViewModel]) {
        let sheetContent = SheetScrollableContent()
        items.forEach { viewModel in
            switch viewModel {
            case .title(let title):
                let view = createHeaderView(title: title)
                let container = embedIntoView(to: view)
                sheetContent.addArrangedSubview(container)
            case .amount(let item):
                let amountView = ItemDetailAmountView()
                amountView.hideStateView()
                amountView.setTopConstraint(8)
                item.setup(amountView)
                let container = embedIntoView(to: amountView)
                sheetContent.addArrangedSubview(container)
            case .sendButton(let title):
                let acceptButton = RedLisboaButton()
                acceptButton.addAction { [weak self] in
                    self?.presenter.didSelectReuseSendAgain()
                }
                acceptButton.set(localizedStylableText: localized(title), state: .normal)
                let container = embedIntoView(acceptButton)
                sheetContent.addArrangedSubview(container)
            case .defaultItem(let item):
                let detail = ItemDetailView()
                item.setup(detail)
                let container = embedIntoView(to: detail)
                sheetContent.addArrangedSubview(container)
            }
        }
        self.removeContent()
        self.addScrollableContent(sheetContent)
        self.showDragIdicator()
        self.show()
    }
}

private extension BizumSendAgainView {
    func createHeaderView(title: TextWithAccessibility) -> UIView {
        let container = UIView()
        let label = UILabel()
        let pointView = PointLine()
        container.addSubview(label)
        container.addSubview(pointView)
        label.translatesAutoresizingMaskIntoConstraints = false
        pointView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            pointView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 25),
            pointView.heightAnchor.constraint(equalToConstant: 1),
            pointView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            pointView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            pointView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        label.font = .santander(family: .text, type: .bold, size: 18)
        label.textColor = .lisboaGray
        label.text = localized(title.text)
        label.accessibilityIdentifier = title.accessibility
        return container
    }

    func embedIntoView(to view: UIView) -> UIView {
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 26),
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        return container
    }

    func embedIntoView(_ button: RedLisboaButton) -> UIView {
        let container = UIView()
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 40),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 26),
            button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            button.topAnchor.constraint(equalTo: container.topAnchor, constant: 15),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }
}
