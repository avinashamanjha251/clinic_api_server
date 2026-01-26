import Vapor

struct SMAdminLoginResponse: Content {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    
    init(token: String, expiresIn: Int = 3600) {
        self.accessToken = token
        self.tokenType = "Bearer"
        self.expiresIn = expiresIn
    }
}
