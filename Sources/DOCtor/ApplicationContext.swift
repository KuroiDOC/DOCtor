import Foundation

public class ApplicationContext {
    public static let main = ApplicationContext()
    
    private var registry: [AnyHashable: () -> Any] = [:]
    private var singletlonsRegistry: [AnyHashable: Any] = [:]
    
    public func register<Service>(_ service: Service.Type,
                                  name: String? = nil,
                                  factory: @escaping () -> Service) {
        let key = ApplicationContext.key(service, name: name)
        registry[key] = factory
    }
    
    public func resolve<Service>(_ service: Service.Type, name: String? = nil) -> Service? {
        let key = ApplicationContext.key(service, name: name)
        return registry[key]?() as? Service
    }
    
    // Whenever possible, creates closure to resolve dependency as a singleton.
    public func registerSingleInstance<Service>(_ service: Service.Type,
                                                name: String? = nil,
                                                factory: @escaping () -> Service) {
        let key = ApplicationContext.key(service, name: name)
        register(service, name: name, factory: { [weak self] () -> Service in
            if let instance = self?.singletlonsRegistry[key] as? Service {
                return instance
            } else {
                let instance = factory()
                self?.singletlonsRegistry[key] = instance
                return instance
            }
        })
    }
    
    private static func key<Service>(_ service: Service.Type, name: String?) -> AnyHashable {
        if let name = name {
            return name
        }
        return ObjectIdentifier(service)
    }
}
