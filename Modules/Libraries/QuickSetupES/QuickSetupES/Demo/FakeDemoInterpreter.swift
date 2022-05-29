class FakeDemoInterpreter: DemoInterpreter {
    func isDemoUser(userName: String) -> Bool {
        return false
    }

    func getDemoUser() -> String? {
        return nil
    }

    func getDefaultDemoUser() -> String {
        return ""
    }
    
    func getAnswerNumber(serviceName: String) -> Int {
        return 0
    }
    
    func setAnswers(_ answers: [String: Int]) {}
}
