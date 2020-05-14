import Foundation

@propertyWrapper
public struct Injectable<T> {
    public var wrappedValue: T

    public init(name: String? = nil, applicationCtx: ApplicationContext? = nil) {
        let ctx = applicationCtx ?? ApplicationContext.main
        let obj = ctx.resolve(T.self, name: name)
                
        precondition(obj != nil, "Failed to inject dependency")
        wrappedValue = obj!
    }
}
