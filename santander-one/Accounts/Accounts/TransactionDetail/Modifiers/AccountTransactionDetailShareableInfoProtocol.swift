public protocol AccountTransactionDetailShareableInfoProtocol {
    func getShareableInfo(
        description: String?,
        alias: String?,
        amount: NSAttributedString?,
        info: [(title: String, description: String)],
        operationDate: String?,
        valueDate: String?
    ) -> String
}
