import Vapor

struct AdminUser: Authenticatable {
    let username: String
}
