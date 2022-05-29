import Foundation

let pusher = Pusher(
    configuration: PusherConfiguration(
        app: .spain,
        compilation: .intern,
        version: "5.6"
    )
)

pusher.send(
    to: "c5546e1e945919db8e40c9a2e0ad05f57c58c4ea01d9b5daff8cf64b91890e1f",
    title: "This is a notification",
    body: "This is the body of the notification",
    type: .mediaUrl(url:"https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png")
)

// MARK: - Examples

/// AccountLandingPush
//pusher.send(
//    to: "a79373603614ca747055447ac73b7f2dad074804ef04057e973ab46dc61a9d4e",
//    title: "This is a notification",
//    body: "This is the body of the notification",
//    type: .accountLandingPush(
//        subscriber: "F314422",
//        transactionInfo: AccountLandingPush(
//            accountName: "Tarjeta Gastos de casa",
//            ccc: "548901",
//            date: "2019-03-19 18:19:00",
//            currency: "EUR",
//            value: "60.42"
//        ),
//        alertInfo: AccountAlertInfo(
//            name: .emittedTransfer,
//            user: "Ignacio García Gutiérrez")
//    )
//)

/// OfferNavigation
//pusher.send(
//    to: "d58eaee09e3977ca070a68a0a1a59ad9a9ca040b7b77000274e167ffd5d60a0d",
//    title: "This is a notification",
//    body: "This is the body of the notification",
//    type: .offerNavigation(offer: "Buzon_correspondencia")
//)

RunLoop.main.run()
