import Foundation

@propertyWrapper
public struct Injectable<T> {
    private var name: String?
    private var container: Container
    private var store = InjectableStore<T>()
    public var wrappedValue: T {
        get {
            if let value = store.value {
                return value
            }
            store.value = container.resolve(name: name, T.self)
            precondition(store.value != nil, "Failed to inject dependency: \(String(describing: T.self)), name: \(name ?? "nil")")
            return store.value!
        }
    }

    public init(name: String? = nil, container: Container = Container.main) {
        self.name = name
        self.container = container
    }
}

private class InjectableStore<T> {
    var value: T?
}
