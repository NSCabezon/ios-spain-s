import Foundation

class LandingPushHeaderViewModel: TableModelViewItem<LandingPushHeaderTableViewCell> {
    private let alertName: LocalizedStylableText
    private let commerce: String
    private let amount: String
    private let day: String?
    private let hour: String?
    private let image: String
    private let cardType: LocalizedStylableText?
    private let cardName: String
    private let cardPan: String?
    private let userName: String?
    private let imageURL: String?
    private let imageLoader: ImageLoader?
    
    init(alertName: LocalizedStylableText, commerce: String, amount: String, day: String?, hour: String?, image: String, cardType: LocalizedStylableText?, cardName: String, cardPan: String, userName: String, dependencies: PresentationComponent, imageURL: String? = nil, imageLoader: ImageLoader? = nil) {
        self.alertName = alertName
        self.commerce = commerce
        self.amount = amount
        self.day = day
        self.hour = hour
        self.image = image
        self.cardType = cardType
        self.cardName = cardName
        self.cardPan = cardPan
        self.userName = userName
        self.imageURL = imageURL
        self.imageLoader = imageLoader
        super.init(dependencies: dependencies)
    }
    
    override func bind(viewCell: LandingPushHeaderTableViewCell) {
        viewCell.setAlertName(alertName: alertName)
        viewCell.setCommerce(commerce: commerce)
        viewCell.setAmount(amount: amount)
        viewCell.setDay(day: day)
        viewCell.setHour(hour: hour)
        viewCell.setImage(image: image)
        viewCell.setCardName(name: cardName)
        viewCell.setCardPan(cardPan: cardPan)
        viewCell.setUserName(userName: userName)
        imageLoader?.load(relativeUrl: imageURL ?? "", imageView: viewCell.cardImageView, placeholder: "defaultCard")
    }
}
