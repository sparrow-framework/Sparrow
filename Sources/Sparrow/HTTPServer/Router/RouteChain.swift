internal struct RouterChain {

    internal let preprocessors: [Router.RequestPreprocessor]
    internal let action: Router.Action
    internal let requestContext: RequestContext

    init?(request: Request, routes: [Router], pathComponents: [String]) {

        guard !routes.isEmpty else {
            return nil
        }

        guard let action = routes.last?.actions[request.method] else {
            return nil
        }

        self.action = action


        var preprocessors: [Router.RequestPreprocessor] = []

        for route in routes {
            if let routeHandler = route.preprocessors[request.method] {
                preprocessors.append(routeHandler)
            }
        }

        self.preprocessors = preprocessors

        var parametersByName: [String: String] = [:]

        for (pathSegment, pathComponent) in zip(routes.map { $0.pathSegment }, pathComponents) {
            guard case .parameter(let name) = pathSegment else {
                continue
            }

            parametersByName[name] = pathComponent
        }

        self.requestContext = RequestContext(
            request: request,
            pathParameters:  PathParameters(contents: parametersByName)
        )
    }
}

extension RouterChain: Responder {

    public func respond(to request: Request) throws -> Response {

        for handler in preprocessors {
            switch try handler(requestContext) {

            case .continue:
                break

            case .break(let response):
                return response
            }
        }
        
        return try action(requestContext)
    }
}
