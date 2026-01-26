import Vapor

struct SMAdminRegisterResponse: Content {
    let name: String
    let username: String
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    init(name: String, username: String, token: String, expiresIn: Int = 3600) {
        self.name = name
        self.username = username
        self.accessToken = token
        self.tokenType = "Bearer"
        self.expiresIn = expiresIn
    }
}
