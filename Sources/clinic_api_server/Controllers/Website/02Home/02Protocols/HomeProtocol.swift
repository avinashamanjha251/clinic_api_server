import Vapor

protocol HomeViewModelProtocol {
    static func getInfo(req: Request) async throws -> Response
}
