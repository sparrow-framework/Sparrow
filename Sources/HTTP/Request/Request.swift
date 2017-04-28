import Core
import Foundation

public struct HTTPRequest: HTTPMessage {
    public enum Method {
        case delete
        case get
        case head
        case post
        case put
        case connect
        case options
        case trace
        case patch
        case other(method: String)
    }

    public var method: Method
    public var url: URL
    public var version: Version
    public var headers: HTTPHeaders
    public var body: HTTPBody
    
    public typealias UpgradeConnection = (HTTPResponse, Core.Stream) throws -> Void
    public var upgradeConnection: UpgradeConnection?

    public init(method: Method, url: URL, version: Version, headers: HTTPHeaders, body: HTTPBody) {
        self.method = method
        self.url = url
        self.version = version
        self.body = body

        var headers = headers

        switch body {
        case let .data(body):
            headers["Content-Length"] = String(body.count)
        default:
            headers["Transfer-Encoding"] = "chunked"
        }

        self.headers = headers
    }
}

extension HTTPRequest {
    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: HTTPHeaders = [:], body: HTTPBody) {
        self.init(
            method: method,
            url: url,
            version: Version(major: 1, minor: 1),
            headers: headers,
            body: body
        )
    }

    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: HTTPHeaders = [:], body: [Byte] = []) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .data(body)
        )
    }

    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: HTTPHeaders = [:], body: DataRepresentable) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .data(body.bytes)
        )
    }

    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: HTTPHeaders = [:], body: Core.InputStream) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .reader(body)
        )
    }

    public init(method: Method = .get, url: URL = URL(string: "/")!, headers: HTTPHeaders = [:], body: @escaping (Core.OutputStream) throws -> Void) {
        self.init(
            method: method,
            url: url,
            headers: headers,
            body: .writer(body)
        )
    }
}

extension HTTPRequest {
    public init?(method: Method = .get, url: String, headers: HTTPHeaders = [:], body: [Byte] = []) {
        guard let url = URL(string: url) else {
            return nil
        }

        self.init(
            method: method,
            url: url,
            headers: headers,
            body: body
        )
    }

    public init?(method: Method = .get, url: String, headers: HTTPHeaders = [:], body: DataRepresentable) {
        self.init(method: method, url: url, headers: headers, body: body.bytes)
    }

    public init?(method: Method = .get, url: String, headers: HTTPHeaders = [:], body: Core.InputStream) {
        guard let url = URL(string: url) else {
            return nil
        }

        self.init(
            method: method,
            url: url,
            headers: headers,
            body: body
        )
    }

    public init?(method: Method = .get, url: String, headers: HTTPHeaders = [:], body: @escaping (Core.OutputStream) throws -> Void) {
        guard let url = URL(string: url) else {
            return nil
        }

        self.init(
            method: method,
            url: url,
            headers: headers,
            body: body
        )
    }
}

extension HTTPRequest {
    public var accept: [MediaType] {
        get {
            var acceptedMediaTypes: [MediaType] = []

            if let acceptString = headers["Accept"] {
                let acceptedTypesString = acceptString.components(separatedBy: ",")

                for acceptedTypeString in acceptedTypesString {
                    let acceptedTypeTokens = acceptedTypeString.components(separatedBy: ";")

                    if acceptedTypeTokens.count >= 1 {
                        let mediaTypeString = acceptedTypeTokens[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        if let acceptedMediaType = try? MediaType(string: mediaTypeString) {
                            acceptedMediaTypes.append(acceptedMediaType)
                        }
                    }
                }
            }

            return acceptedMediaTypes
        }

        set(accept) {
            headers["Accept"] = accept.map({$0.type + "/" + $0.subtype}).joined(separator: ", ")
        }
    }

    public var cookies: Set<HTTPCookie> {
        get {
            return headers["Cookie"].flatMap({Set<HTTPCookie>(cookieHeader: $0)}) ?? []
        }

        set(cookies) {
            headers["Cookie"] = cookies.map({$0.description}).joined(separator: ", ")
        }
    }

    public var authorization: String? {
        get {
            return headers["Authorization"]
        }

        set(authorization) {
            headers["Authorization"] = authorization
        }
    }

    public var host: String? {
        get {
            return headers["Host"]
        }

        set(host) {
            headers["Host"] = host
        }
    }

    public var userAgent: String? {
        get {
            return headers["User-Agent"]
        }

        set(userAgent) {
            headers["User-Agent"] = userAgent
        }
    }
}

extension HTTPRequest : CustomStringConvertible {
    public var requestLineDescription: String {
        return String(describing: method) + " " + url.absoluteString + " HTTP/" + String(describing: version.major) + "." + String(describing: version.minor) + "\n"
    }

    public var description: String {
        return requestLineDescription + headers.description
    }
}

extension HTTPRequest : CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}