import Testing
@testable import DOCtor

@Suite(.serialized)
class DOCtorTests {
    struct Foo {
        @Injectable var bar: Bar
        @Injectable(name: "Bar2") var bar2: Bar
    }

    struct Bar {
        var msg: String
    }

    struct Baz { }

    class Singleton {
        var msg: String

        init(msg: String) {
            self.msg = msg
        }
    }

    deinit {
        Task {
            await Container.main.reset()
        }
    }

    @Test
    @MainActor
    func registerServices() throws {
        Container.main.register(Factory { Foo() })
        Container.main.register(Factory { Bar(msg: "HI") })
        Container.main.register(Factory(name: "Bar2") { Bar(msg: "BYE") })

        let foo: Foo = Container.main.strictResolve()
        #expect(foo.bar.msg == "HI")
        #expect(foo.bar2.msg == "BYE")

        Container.main.register(Single { Singleton(msg: "Singleton") })
        let s1 = Container.main.resolve(Singleton.self)
        let s2 = Container.main.resolve(Singleton.self)
        #expect(s1 === s2)

        Container.main.register(Factory(name: "FakeSingleton") { Singleton(msg: "Singleton") })
        let s3 = Container.main.resolve(name: "FakeSingleton", Singleton.self)
        let s4 = Container.main.resolve(name: "FakeSingleton", Singleton.self)
        #expect(s3 !== s4)

        Container.main.register(Single(name: "singleBar") { Bar(msg: "Struct") })
        var s5 = Container.main.resolve(name: "singleBar", Bar.self)
        var s6 = Container.main.resolve(name: "singleBar", Bar.self)
        Self.compareMemAddress(p1: &s5, p2: &s6) { p1, p2 in
            #expect(p1 != p2)
        }

        Container.main.register(Factory(name: "Clash") { Bar(msg: "Clash") })
        Container.main.register(Factory(name: "Clash") { Baz() })
        let s7 = Container.main.strictResolve(name: "Clash", Bar.self)
        let s8 = Container.main.resolve(name: "Clash", Baz.self)
        #expect(s7.msg == "Clash")
        try #require(s8 != nil)

        Container.main.reset()
        try #require(Container.main.resolve(Foo.self) == nil)
    }

    @Test
    @MainActor
    func requestBuilder() throws {
        Container.main.register {
            Factory { Foo() }
            Factory { Bar(msg: "HI") }
            Factory(name: "Bar2") { Bar(msg: "BYE") }
            Single(name: "singleBar") { Bar(msg: "Struct") }
        }

        let foo = Container.main.resolve(Foo.self)
        try #require(foo != nil)
        #expect(foo?.bar.msg == "HI")
        #expect(foo?.bar2.msg == "BYE")

        var s1 = Container.main.resolve(name: "singleBar", Bar.self)
        var s2 = Container.main.resolve(name: "singleBar", Bar.self)
        Self.compareMemAddress(p1: &s1, p2: &s2) { p1, p2 in
            #expect(p1 != p2)
        }
    }

    @Test
    func concurrentAccesses() async throws {
        await withTaskGroup(of: Void.self) { taskGroup in
            for i in 1...20 {
                taskGroup.addTask {
                    await Container.main.register(Single(name: "Singleton-\(i)") {
                        Singleton(msg: "Singleton-\(i)")
                    })
                }
            }
        }

        for i in 1...20 {
            Task { @MainActor in
                let obj = Container.main.strictResolve(name: "Singleton-\(i)", Singleton.self)
                try #require(obj != nil)
            }
        }
    }

    static func compareMemAddress<T>(p1: UnsafePointer<T>,p2: UnsafePointer<T>, closure: (UnsafePointer<T>,UnsafePointer<T>) -> Void) {
        closure(p1,p2)
    }
}
