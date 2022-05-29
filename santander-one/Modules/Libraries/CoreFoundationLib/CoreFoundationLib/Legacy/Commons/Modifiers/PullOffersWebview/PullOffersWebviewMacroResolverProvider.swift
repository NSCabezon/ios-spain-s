public protocol PullOffersWebviewMacroResolverProvider {
    func getValueForMacro(_ macro: String) -> String?
}
