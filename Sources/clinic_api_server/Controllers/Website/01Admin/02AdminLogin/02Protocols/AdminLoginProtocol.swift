import Vapor

protocol AdminLoginProtocol {
    static func login(req: Request) async throws -> Response
}
