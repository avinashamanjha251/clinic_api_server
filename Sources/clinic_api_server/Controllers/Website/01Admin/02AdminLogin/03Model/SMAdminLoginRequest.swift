import Vapor

struct SMAdminLoginRequest: Content {
    let username: String
    let password: String
}
