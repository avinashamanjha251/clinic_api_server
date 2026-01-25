import Vapor

protocol AboutViewModelProtocol {
    static func getData(req: Request) async throws -> Response
}
