import Vapor

struct SimpleBasicAuthMiddleware: AsyncMiddleware {
    // Default credentials if explicit env vars are not set
    // Ideally these should always be set in production
    private let expectedUser: String
    private let expectedPass: String
    
    init() throws {
        guard let expectedUser = Environment.get(environmentKey: .BASIC_AUTH_USERNAME) else {
            throw Abort(.internalServerError, reason: "Basic Auth user name not found")
        }
        guard let expectedPass = Environment.get(environmentKey: .BASIC_AUTH_PASSWORD) else {
            throw Abort(.internalServerError, reason: "Basic Auth password not found")
        }
        self.expectedUser = expectedUser
        self.expectedPass = expectedPass
    }

    func respond(to request: Request,
                 chainingTo next: AsyncResponder) async throws -> Response {
        guard let authorization = request.headers.basicAuthorization else {
            let headers: HTTPHeaders = ["WWW-Authenticate": "Basic realm=\"Appointment Booking\""]
            throw Abort(.unauthorized,
                        headers: headers,
                        reason: "Authentication required")
        }
        guard authorization.username == expectedUser && authorization.password == expectedPass else {
            throw Abort(.unauthorized,
                        reason: "Invalid credentials")
        }
        return try await next.respond(to: request)
    }
}
