import Foundation

public class Container {
    public static let main = Container()
    
    private var registry: [AnyHashable: Any] = [:]
    
    public func register<T: Registrable>(_ registrable: T,
                                  name: String? = nil) {
        let key = Container.key(T.Service.self, name: name)
        registry[key] = registrable
    }
    
    public func resolve<Service>(_ service: Service.Type, name: String? = nil) -> Service? {
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
    
    private static func key<Service>(_ service: Service.Type, name: String?) -> AnyHashable {
        if let name = name {
            return name
        }
        return ObjectIdentifier(service)
    }
}

public protocol Registrable {
    associatedtype Service
    var service: Service { get }
}

public struct Factory<Service>: Registrable {
    public typealias Builder = () -> Service
    private let builder: Builder
    
    public init(_ builder: @escaping Builder) {
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
    
    public init(_ builder: @escaping Builder) {
        self.builder = builder
    }
    
    public var service: Service {
        if let instance = instance { return instance }
        let newInstance = builder()
        instance = newInstance
        return newInstance
    }
    
}
