import Foundation

// A lightweight in-process "backend" scaffold that serves stubbed
// API responses for development. It intercepts requests to
// https://api.goingvegan.app/referrals/* and returns JSON or status codes
// as if a real backend existed.
final class StubbedReferralBackend: URLProtocol {
    private static let queue = DispatchQueue(label: "StubbedReferralBackend.queue", attributes: .concurrent)
    private static var _isRegistered = false

    private struct Store {
        var validReferrerCodes: Set<String> = ["ABC123", "VEGAN1", "PLANT2", "GREEN3"]
        var awardedCounts: [String: Int] = [:]
        var trackedEvents: [(referrer: String, referee: String, date: Date)] = []
    }

    private static var store = Store()

    // MARK: - Registration / Session helpers

    static func register() {
        queue.sync(flags: .barrier) {
            guard _isRegistered == false else { return }
            URLProtocol.registerClass(StubbedReferralBackend.self)
            _isRegistered = true
        }
    }

    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubbedReferralBackend.self]
        return URLSession(configuration: config)
    }

    // MARK: - URLProtocol overrides

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        guard url.host == "api.goingvegan.app" else { return false }
        guard url.path.hasPrefix("/referrals") else { return false }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        let method = request.httpMethod ?? "GET"
        do {
            let (status, headers, data) = try Self.handle(url: url, method: method, body: request.httpBody)
            let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }

    // MARK: - Routing / Handlers

    private static func handle(url: URL, method: String, body: Data?) throws -> (Int, [String:String], Data?) {
        switch (method, url.path) {
        case ("GET", "/referrals/verify"):
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
            let code = items?.first(where: { $0.name == "code" })?.value ?? ""
            let isValid = queue.sync { store.validReferrerCodes.contains(code) }
            let payload = ["valid": isValid]
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            if isValid {
                return (200, ["Content-Type": "application/json"], data)
            } else {
                return (404, ["Content-Type": "application/json"], data)
            }

        case ("POST", "/referrals/award"):
            guard let body = body,
                  let json = try JSONSerialization.jsonObject(with: body) as? [String: Any],
                  let code = json["referrerCode"] as? String else {
                return (400, [:], nil)
            }
            let ok = queue.sync { store.validReferrerCodes.contains(code) }
            if ok {
                queue.async(flags: .barrier) {
                    store.awardedCounts[code, default: 0] += 1
                }
                return (204, [:], nil)
            } else {
                return (404, [:], nil)
            }

        case ("POST", "/referrals/track"):
            guard let body = body,
                  let json = try JSONSerialization.jsonObject(with: body) as? [String: Any],
                  let referrer = json["referrerCode"] as? String,
                  let referee = json["refereeReferralCode"] as? String else {
                return (400, [:], nil)
            }
            queue.async(flags: .barrier) {
                store.trackedEvents.append((referrer: referrer, referee: referee, date: Date()))
                // Add the new user's code to valid set so they can refer others later
                store.validReferrerCodes.insert(referee)
            }
            return (204, [:], nil)

        default:
            return (501, [:], nil)
        }
    }

    // MARK: - Test helpers

    static func reset() {
        queue.async(flags: .barrier) {
            store = Store()
        }
    }

    static func addValidReferrerCode(_ code: String) {
        queue.async(flags: .barrier) {
            store.validReferrerCodes.insert(code)
        }
    }
}
