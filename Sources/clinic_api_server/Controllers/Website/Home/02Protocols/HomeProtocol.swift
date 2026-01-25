import Vapor

protocol HomeViewModelProtocol {
    static func getInfo(req: Request) async throws -> Response
    static func getServicesSummary(req: Request) async throws -> Response
}
