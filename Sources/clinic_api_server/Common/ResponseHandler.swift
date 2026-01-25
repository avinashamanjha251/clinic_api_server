import Vapor

struct ResponseHandler {
    struct ResponseData<T: Content>: Content {
        let success: Bool
        let message: String
        let code: Int
        let data: T?
    }

    struct EmptyData: Content {}

    static func success<T: Content>(
        message: String = "success",
        statusCode: HTTPResponseStatus = .ok,
        data: T? = nil,
        on request: Request
    ) async -> Response {
        let responseData = ResponseData(
            success: true,
            message: message,
            code: Int(statusCode.code),
            data: data
        )
        // Encode manually to ensure status code is set on the response object
        do {
            let response = try await responseData.encodeResponse(for: request)
            response.status = statusCode
            return response
        } catch {
            return await Self.error(error, on: request)
        }
    }

    static func error(
        _ error: Error,
        on request: Request,
        statusCodeOverride: HTTPResponseStatus? = nil
    ) async -> Response {
        let status = statusCodeOverride ?? (error as? AbortError)?.status ?? .internalServerError
        let reason = (error as? AbortError)?.reason ?? error.localizedDescription
        
        // Don't leak internal details in prod if not an AbortError? 
        // For now we just return the simple structure
        
        let responseData = ResponseData<EmptyData>(
            success: false,
            message: reason,
            code: Int(status.code),
            data: nil
        )
        
        
        do {
            let response = try await responseData.encodeResponse(for: request)
            response.status = status
            return response
        } catch {
            return Response(status: .internalServerError)
        }
    }
}
