import Vapor

protocol AdminRegisterProtocol {
    static func register(req: Request) async throws -> Response
}
