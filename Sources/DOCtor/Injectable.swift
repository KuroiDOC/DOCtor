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
            store.value = container.strictResolve(name: name, T.self)
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
