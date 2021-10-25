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

Container.main.register(Factory { Foo() })
Container.main.register(Factory { Bar(msg: "HI") })
Container.main.register(Factory { Bar(msg: "BYE") }, name: "Bar2")

let foo = Container.main.resolve(Foo.self)

Container.main.register(Single { Singleton(msg: "Singleton") })
Container.main.register(Factory { Singleton(msg: "NotASingleton") }, name: "FakeSingleton")

let singleton = Container.main.resolve(Singleton.self)

```

