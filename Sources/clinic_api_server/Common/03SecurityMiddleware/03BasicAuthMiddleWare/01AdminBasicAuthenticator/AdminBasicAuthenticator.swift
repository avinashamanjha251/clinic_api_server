import Vapor

struct AdminBasicAuthenticator: AsyncBasicAuthenticator {
    typealias User = AdminUser

    private let expectedUser: String
    private let expectedPass: String
    
    init() throws {
        guard let expectedUser = Environment.get(environmentKey: .BASIC_AUTH_ADMIN_USERNAME) else {
            throw Abort(.internalServerError, reason: "Basic Auth user name not found")
        }
        guard let expectedPass = Environment.get(environmentKey: .BASIC_AUTH_ADMIN_PASSWORD) else {
            throw Abort(.internalServerError, reason: "Basic Auth password not found")
        }
        self.expectedUser = expectedUser
        self.expectedPass = expectedPass
    }
    
    func authenticate(basic: BasicAuthorization, for request: Request) async throws {
        if basic.username == expectedUser && basic.password == expectedPass {
            request.auth.login(AdminUser(username: basic.username))
        }
    }
}
