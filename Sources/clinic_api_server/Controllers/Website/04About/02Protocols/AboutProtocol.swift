import Vapor

protocol AboutViewModelProtocol {
    static func getInfo(req: Request) async throws -> Response
    static func getTeam(req: Request) async throws -> Response
    static func getFacility(req: Request) async throws -> Response
    static func getCommunity(req: Request) async throws -> Response
}
