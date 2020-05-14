# DOCtor

Simple lightweight dependency injector. Works with Swift 5.2 and higher.

Usage examples:
```swift
struct Foo {
    @Injectable var bar: Bar
    @Injectable(name: "Bar2") var bar2: Bar
}

struct Bar {
    var msg: String
}

class Singleton {
    var msg: String

    init(msg: String) {
        self.msg = msg
    }
}

ApplicationContext.main.register(Foo.self) { Foo() }
ApplicationContext.main.register(Bar.self) { Bar(msg: "HI") }
ApplicationContext.main.register(Bar.self, name: "Bar2") { Bar(msg: "BYE") }

let foo = ApplicationContext.main.resolve(Foo.self)

ApplicationContext.main.registerSingleton(Singleton.self) { Singleton(msg: "Singleton") }
ApplicationContext.main.register(Singleton.self, name: "FakeSingleton") { Singleton(msg: "Singleton") }

let singleton = ApplicationContext.main.resolve(Singleton.self)

```

