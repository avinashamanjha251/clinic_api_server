import Vapor

struct AdminBasicAuthenticator: AsyncBasicAuthenticator {
    typealias User = AdminUser

    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        let adminUsername = Environment.get(environmentKey: .BASIC_AUTH_USERNAME) ?? "admin"
        let adminPassword = Environment.get(environmentKey: .BASIC_AUTH_PASSWORD) ?? "password"

        if basic.username == adminUsername && basic.password == adminPassword {
            request.auth.login(AdminUser(username: basic.username))
        }
    }
}
