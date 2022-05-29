public protocol DemoInterpreter {
    func isDemoUser(userName: String) -> Bool

    func getDemoUser() -> String?
    
    func getDefaultDemoUser() -> String

    func getAnswerNumber(serviceName: String) -> Int
    
    func setAnswers(_ answers: [String: Int])
}
