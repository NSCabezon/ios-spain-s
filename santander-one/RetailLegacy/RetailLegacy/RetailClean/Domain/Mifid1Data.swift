enum Mifid1Status {
    case none
    case simple(simpleVariableText: String?)
    case complex(simpleVariableText: String?, questionText: String, textToValidate: String)
    case mfm([(questionTextMfm: String, textToValidateMfm: String)])
    case simpleMfm(simpleVariableText: String?, mfmClausules: [(questionTextMfm: String, textToValidateMfm: String)])
    case complexMfm(simpleVariableText: String?, questionText: String, textToValidate: String, mfmClausules: [(questionTextMfm: String, textToValidateMfm: String)])
}

struct Mifid1Data {
    let userIsPb: Bool
    let mifid1Status: Mifid1Status
}

extension Mifid1Data: OperativeParameter {}
extension Mifid1Status: OperativeParameter {} 
