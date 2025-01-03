import Foundation

@propertyWrapper
public struct Injectable<T>: @unchecked Sendable {
    private var name: String?
    private var container: Container
    private var store = InjectableStore<T>()
    @MainActor public var wrappedValue: T {
        get {
            if let value = store.value {
                return value
            }
            let value = container.strictResolve(name: name, T.self)
            store.value = value
            return value
        }
    }

    public init(name: String? = nil, container: Container = Container.main) {
        self.name = name
        self.container = container
    }
}

private final class InjectableStore<T> {
    var value: T?
}
