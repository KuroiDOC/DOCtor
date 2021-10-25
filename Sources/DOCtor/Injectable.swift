import Foundation

@propertyWrapper
public struct Injectable<T> {
    public var wrappedValue: T

    public init(name: String? = nil, applicationCtx: Container = Container.main) {
        let ctx = applicationCtx
        let obj = ctx.resolve(T.self, name: name)
                
        precondition(obj != nil, "Failed to inject dependency")
        wrappedValue = obj!
    }
}
