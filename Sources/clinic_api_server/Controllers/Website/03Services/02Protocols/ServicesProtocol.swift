import Vapor

protocol ServicesViewModelProtocol {
    static func getList(req: Request) async throws -> Response
}
