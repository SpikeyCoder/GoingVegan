import Foundation

protocol ReferralAPI {
    func verifyReferrer(code: String) async throws -> Bool
    func awardReferrer(forCode code: String) async throws
    func trackSuccessfulReferral(referrerCode: String, refereeReferralCode: String) async throws
}

struct APIError: Error, LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

final class DefaultReferralAPI: ReferralAPI {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "https://api.goingvegan.app")!, session: URLSession? = nil) {
        self.baseURL = baseURL
        if let session = session {
            self.session = session
        } else {
            #if DEBUG
            StubbedReferralBackend.register()
            self.session = StubbedReferralBackend.makeSession()
            #else
            self.session = .shared
            #endif
        }
    }

    func verifyReferrer(code: String) async throws -> Bool {
        var components = URLComponents(url: baseURL.appendingPathComponent("/referrals/verify"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "code", value: code)]
        guard let url = components.url else { throw APIError(message: "Invalid URL") }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw APIError(message: "Invalid response") }
        if http.statusCode == 200 {
            if let valid = try? JSONDecoder().decode(VerifyResponse.self, from: data).valid {
                return valid
            }
            return true
        } else if http.statusCode == 404 {
            return false
        } else {
            throw APIError(message: "Server error: \(http.statusCode)")
        }
    }

    func awardReferrer(forCode code: String) async throws {
        let url = baseURL.appendingPathComponent("/referrals/award")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["referrerCode": code]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError(message: "Failed to award referrer")
        }
    }

    func trackSuccessfulReferral(referrerCode: String, refereeReferralCode: String) async throws {
        let url = baseURL.appendingPathComponent("/referrals/track")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "referrerCode": referrerCode,
            "refereeReferralCode": refereeReferralCode
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        let (_, response) = try await session.data(for: req)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw APIError(message: "Failed to track referral")
        }
    }

    private struct VerifyResponse: Decodable { let valid: Bool }
}
