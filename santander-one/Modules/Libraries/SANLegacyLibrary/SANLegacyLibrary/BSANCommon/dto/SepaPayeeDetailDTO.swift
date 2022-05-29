public struct SepaPayeeDetailDTO: Codable {
    let payeeCode: String //service field: codPayee

    public init(payeeCode: String) {
        self.payeeCode = payeeCode
    }
}
