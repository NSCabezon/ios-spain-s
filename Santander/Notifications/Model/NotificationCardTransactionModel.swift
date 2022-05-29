//
//  NotificationCardTransactionModel.swift
//  Santander
//
//  Created by alvola on 07/05/2021.
//
import CorePushNotificationsService

struct CardLandingPushTransaction: LandingPushTransactionDataSettings {
    var user: String
    var cardName: String
    var cardType: String
    var pan: String
    var bin: String
    var transanction: TransactionSettings?
    var alert: TransactionAlertSettings?
    
    init(transactionInfo: [AnyHashable: Any]) {
        user = transactionInfo["user"] as? String ?? ""
        cardName = transactionInfo["cardName"] as? String ?? ""
        cardType = transactionInfo["cardType"] as? String ?? ""
        pan = transactionInfo["pan"] as? String ?? ""
        bin = transactionInfo["bin"] as? String ?? ""
        transanction = CardTransactionSettings(transaction: transactionInfo["transaction"] as? [AnyHashable: Any])
        alert = TransactionAlert(alert: transactionInfo["alert"] as? [AnyHashable: Any])
    }
}

struct CardTransactionSettings: TransactionSettings {
    var amountValue: Decimal?
    var amountCurrency: String?
    var commerce: String?
    var date: String?
    
    init(transaction: [AnyHashable: Any]?) {
        amountValue = (transaction?["amount"] as? [AnyHashable: Any])?["value"] as? Decimal
        amountCurrency = (transaction?["amount"] as? [AnyHashable: Any])?["currency"] as? String
        commerce = transaction?["commerce"] as? String
        date = transaction?["date"] as? String
    }
}

struct TransactionAlert: TransactionAlertSettings {
    var name: String?
    var category: String?
    
    init(alert: [AnyHashable: Any]?) {
        name = alert?["commerce"] as? String
        category = alert?["date"] as? String
    }
}
