//
//  NavigationView.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/21/20.
//

import SwiftUI

public struct MorphNavigationView<Content: View>: View {
    
    private let content: Content
    
    @Environment(\.navigationViewStyle) var style
    @State var title: Text = Text("")
    @State var previousTitle: [Text] = []
    @State var navigationBarButtonItems: NavigationBarButtomItems = NavigationBarButtomItems()
    @State var navigationBarBackground: AnyView = AnyView(EmptyView())
    @State var navigationBarTintColor: Color = Color(.tertiarySystemBackground)
    @ObservedObject private var navigationStack = NavigationStack()
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var transitions: (push: AnyTransition, pop: AnyTransition) {
        let push = AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        let pop = AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
        
        return (push, pop)
    }
    
    public var body: some View {
        
        let showRoot = self.navigationStack.currentPage == nil
        let navigationType = self.navigationStack.navigationType
        
        return
            Group {
                if showRoot {
                    self.style?.makeBody(configuration:
                        self.configuration(for:
                            self.content
                                .id("root")
                                .transition(navigationType == .push ? transitions.push : transitions.pop)
                        )
                    )
                    
                } else {
                    self.style?.makeBody(configuration:
                        self.configuration(for:
                            self.navigationStack.currentPage!.body
                                .id(self.navigationStack.currentPage!.id)
                                .transition(navigationType == .push ? transitions.push : transitions.pop)
                        )
                    )
                }
            }
            .environment(\.navigationStack, self.navigationStack)
    }
    
    private func configuration<V: View>(for view: V) -> NavigationViewStyleConfiguration {
        let content = view
            .onPreferenceChange(NavigationBarTitlePreferences.self) {
                if self.navigationStack.navigationType == .push {
                    self.previousTitle.append(self.title)
                } else {
                    if !self.previousTitle.isEmpty {
                        self.previousTitle.removeLast()
                    }
                    
                }
                self.title = $0
            }
            .onPreferenceChange(NavigationBarButtonItemsPreferences.self) { self.navigationBarButtonItems = $0 }
            .onPreferenceChange(NavigationBarBackgroundPreference.self) { self.navigationBarBackground = $0.body }
            .onPreferenceChange(NavigationBarTintColorPreference.self) { color in
                if let color = color {
                    self.navigationBarTintColor = color
                }
        }
            
        
        let configuration = NavigationViewStyleConfiguration(content: .init(content),
                                                             navigationBarItems: self.navigationBarButtonItems,
                                                             navigationBarTitle: self.title,
                                                             previousNavigationBarTitle: self.previousTitle.last,
                                                             navigationBarBackground: .init(self.navigationBarBackground),
                                                             navigationBarTintColor: self.navigationBarTintColor)
        
        return configuration
    }
    
}

struct NavigationBarTitlePreferences: PreferenceKey {
    typealias Value = Text

    static var defaultValue: Text { Text("") }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct NavigationBarButtonItemsPreferences: PreferenceKey {
    typealias Value = NavigationBarButtomItems

    static var defaultValue: NavigationBarButtomItems { NavigationBarButtomItems() }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

struct NavigationBarBackgroundPreference: PreferenceKey {
    
    struct BackgroundContent: View, Equatable {
        static func == (lhs: NavigationBarBackgroundPreference.BackgroundContent, rhs: NavigationBarBackgroundPreference.BackgroundContent) -> Bool {
            lhs.id == rhs.id
        }
        
        init<V: View>(_ view: V) {
            self.id = UUID().uuidString
            self.body = AnyView(view.id(self.id))
        }
        
        private let id: String
        
        var body: AnyView
    }
    
    typealias Value = BackgroundContent

    static var defaultValue: BackgroundContent { BackgroundContent(EmptyView()) }
    
    static func reduce(value: inout BackgroundContent, nextValue: () -> BackgroundContent) {
        value = nextValue()
    }
}

struct NavigationBarTintColorPreference: PreferenceKey {
    typealias Value = Color?

    static var defaultValue: Color? { return nil }
    
    static func reduce(value: inout Color?, nextValue: () -> Color?) {
        value = nextValue()
    }
}

// Main idea using stack representation was taken from https://github.com/biobeats/swiftui-navigation-stack/blob/master/Sources/NavigationStack/NavigationStack.swift
// Thanks!

enum NavigationType {
    case push
    case pop
}

enum PopDestination {
    case previous
    case root
    case view(withId: String)
}

class NavigationStack: ObservableObject {
    
    struct Page: View, Equatable, Identifiable {
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        let id: String
        var body: AnyView
    }
    
    private(set) var navigationType = NavigationType.push
    
    private var stack = Stack() {
        didSet {
            currentPage = self.stack.peek()
        }
    }
    
    var canPopUp: Bool {
        return !self.stack.pages.isEmpty
    }
    
    @Published var currentPage: Page?
    
    public func push<Element: View>(_ element: Element, withId identifier: String? = nil) {
        withAnimation {
            self.navigationType = .push
            self.stack.push(Page(id: identifier ?? UUID().uuidString, body: AnyView(element)))
        }
    }

    public func pop(to: PopDestination = .previous) {
        withAnimation {
            self.navigationType = .pop
            switch to {
            case .root:
                self.stack.popToRoot()
            case .view(let viewId):
                self.stack.pop(to: viewId)
            default:
                self.stack.popToPrevious()
            }
        }
    }
    
    struct Stack {
        private(set) var pages: [Page] = []
        
        func peek() -> Page? {
            return self.pages.last
        }
        
        mutating func push(_ element: Page) {
            
            if self.pages.contains(element) {
                fatalError("Pushed element already exists on stack by id: \(element.id)")
            }
            
            self.pages.append(element)
        }
        
        mutating func popToPrevious() {
            _ = self.pages.popLast()
        }
        
        mutating func pop(to identifier: Page.ID) {
            guard let index = self.pages.firstIndex(where: { $0.id == identifier }) else {
                fatalError("View by id \(identifier) doesn't exists on stack")
            }
            
            self.pages.removeLast(self.pages.count - (index + 1))
        }
        
        mutating func popToRoot() {
            _ = pages.removeAll()
        }
    }
    
}

struct NavigationStackKey: EnvironmentKey {
    static var defaultValue: NavigationStack?
}

extension EnvironmentValues {
    var navigationStack: NavigationStack? {
        get { self[NavigationStackKey.self] }
        set { self[NavigationStackKey.self] = newValue }
    }
}


/// A view that controls a navigation presentation.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct NavigationButton<Label: View, Destination: View>: View {
    
    private let label: Label
    private let destination: Destination
    
    @Environment(\.navigationStack) var stack: NavigationStack?
    
    @Binding private var isExternalActive: Bool
    @Binding private var isInternalActive: Bool

    /// Creates an instance that presents `destination`.
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        let isInternalActive = State(wrappedValue: false)
        self._isExternalActive = isInternalActive.projectedValue
        self._isInternalActive = isInternalActive.projectedValue
    }

    /// Creates an instance that presents `destination` when active.
    public init(destination: Destination, isActive: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        self._isExternalActive = isActive
        self._isInternalActive = isActive
    }

    /// Creates an instance that presents `destination` when `selection` is set
    /// to `tag`.
//    public init<V>(destination: Destination, tag: V, selection: Binding<V?>, @ViewBuilder label: () -> Label) where V : Hashable {
//        self.destination = destination
//        self.label = label()
//    }

    /// Declares the content and behavior of this view.
    public var body: some View {
        
        if self.isInternalActive && self.stack != nil {
            DispatchQueue.main.async {
                self.isInternalActive = false
                self.push()
            }
        }
        
        return
            Group {
                if self.stack == nil {
                    NavigationLink(destination: self.destination, isActive: self.$isInternalActive, label: {
                        self.label.onTapGesture {
                            self.isInternalActive = true
                            print(self.isInternalActive)
                        }
                    })
                } else {
                    Button(action: self.push, label: { self.label })
                }
        }
    }
    
    private func push() {
        stack?.push(self.destination, withId: UUID().uuidString)
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension NavigationButton where Label == Text {

    /// Creates an instance that presents `destination`, with a `Text` label
    /// generated from a title string.
    public init(_ titleKey: LocalizedStringKey, destination: Destination) {
        self.label = Text(titleKey)
        self.destination = destination
        let isInternalActive = State(wrappedValue: false)
        self._isExternalActive = isInternalActive.projectedValue
        self._isInternalActive = isInternalActive.projectedValue
    }

    /// Creates an instance that presents `destination`, with a `Text` label
    /// generated from a title string.
    public init<S>(_ title: S, destination: Destination) where S : StringProtocol {
        self.label = Text(title)
        self.destination = destination
        let isInternalActive = State(wrappedValue: false)
        self._isExternalActive = isInternalActive.projectedValue
        self._isInternalActive = isInternalActive.projectedValue
    }

    /// Creates an instance that presents `destination` when active, with a
    /// `Text` label generated from a title string.
    public init(_ titleKey: LocalizedStringKey, destination: Destination, isActive: Binding<Bool>) {
        self.label = Text(titleKey)
        self.destination = destination
        self._isExternalActive = isActive
        self._isInternalActive = isActive
    }

    /// Creates an instance that presents `destination` when active, with a
    /// `Text` label generated from a title string.
    public init<S>(_ title: S, destination: Destination, isActive: Binding<Bool>) where S : StringProtocol {
        self.label = Text(title)
        self.destination = destination
        self._isExternalActive = isActive
        self._isInternalActive = isActive
    }

//    /// Creates an instance that presents `destination` when `selection` is set
//    /// to `tag`, with a `Text` label generated from a title string.
//    public init<V>(_ titleKey: LocalizedStringKey, destination: Destination, tag: V, selection: Binding<V?>) where V : Hashable {
//
//    }
//
//    /// Creates an instance that presents `destination` when `selection` is set
//    /// to `tag`, with a `Text` label generated from a title string.
//    public init<S, V>(_ title: S, destination: Destination, tag: V, selection: Binding<V?>) where S : StringProtocol, V : Hashable {
//
//    }
}
