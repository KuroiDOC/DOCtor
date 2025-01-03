import Foundation

@MainActor
public final class Container: Sendable {
    nonisolated public static let main = Container()

    private var registry: [AnyHashable: Any] = [:]

    nonisolated init() {}

    public func register<T: Registrable>(_ registrable: T) {
        let key = Container.key(T.Service.self, name: registrable.name)
        registry[key] = registrable
    }

    public func resolve<Service>(name: String? = nil, _ service: Service.Type) -> Service? {
        let key = Container.key(service, name: name)
        switch registry[key] {
        case let obj as Single<Service>:
            return obj.service
        case let obj as Factory<Service>:
            return obj.service
        default:
            return nil
        }
    }

    public func strictResolve<Service>(name: String? = nil, _ service: Service.Type) -> Service {
        guard let obj = self.resolve(name: name, service) else {
            preconditionFailure("Failed to resolve dependency: \(String(describing: Service.self)), name: \(name ?? "nil")")
        }
        return obj
    }

    public func strictResolve<Service>(name: String? = nil) -> Service {
        strictResolve(name: name, Service.self)
    }

    private static func key<Service>(_ service: Service.Type, name: String?) -> AnyHashable {
        Key(name: name, identifier: ObjectIdentifier(service))
    }

    /// Clear DI graph
    public func reset() {
        registry = [:]
    }
}

private struct Key: Hashable {
    var name: String?
    var identifier: ObjectIdentifier
}

public protocol Registrable {
    associatedtype Service
    var name: String? { get set }
    var service: Service { get }
}

public struct Factory<Service>: Registrable {
    public typealias Builder = () -> Service
    var builder: Builder
    public var name: String?

    public init(name: String? = nil, _ builder: @escaping Builder) {
        self.name = name
        self.builder = builder
    }

    public var service: Service {
        builder()
    }
}

public class Single<Service>: Registrable {
    public typealias Builder = () -> Service
    private let builder: Builder
    private var instance: Service?
    public var name: String?

    public init(name: String? = nil, _ builder: @escaping Builder) {
        self.name = name
        self.builder = builder
    }

    public var service: Service {
        if let instance = instance { return instance }
        let newInstance = builder()
        instance = newInstance
        return newInstance
    }
}
