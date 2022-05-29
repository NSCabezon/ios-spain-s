enum MifidAdviceState {
    case none
    case adviceBlocking(title: String?, message: String)
    case adviceAndContinue(title: String?, message: String)
}
