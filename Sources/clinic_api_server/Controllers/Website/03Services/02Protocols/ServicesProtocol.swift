import Vapor

protocol ServicesViewModelProtocol {
    static func getList(req: Request) async throws -> Response
    static func getDetail(req: Request) async throws -> Response
}
