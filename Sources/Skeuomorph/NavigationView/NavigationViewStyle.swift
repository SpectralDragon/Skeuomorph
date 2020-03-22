//
//  NavigationStyle.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/21/20.
//

import SwiftUI

public struct DumpingEnvironment<V: View>: View {
    @Environment(\.self) var env
    let content: V
    
    public init(_ content: V) {
        self.content = content
    }
    
    public var body: some View {
        dump(env)
        return content
    }
}

public extension View {
    func navigationBarTitle(_ text: Text) -> some View {
        self.preference(key: NavigationBarTitlePreferences.self, value: text)
        .navigationBarTitle(text, displayMode: .inline)
    }
    
    func navigationBarTitle(_ string: String) -> some View {
        self.preference(key: NavigationBarTitlePreferences.self, value: Text(string))
        .navigationBarTitle(Text(string), displayMode: .inline)
    }
    
    func navigationBarBackground<V: View>(_ view: V) -> some View {
        self.preference(key: NavigationBarBackgroundPreference.self, value: .init(view))
    }
    
    func navigationBarTintColor(_ color: Color) -> some View {
        self.preference(key: NavigationBarTintColorPreference.self, value: color)
    }
}

public struct NavigationBarButtomItems: Equatable {
    public struct Items: View, Equatable {
        
        public static func == (lhs: NavigationBarButtomItems.Items, rhs: NavigationBarButtomItems.Items) -> Bool {
            lhs.id == rhs.id
        }
        
        private let id: String
        
        init<T: View>(_ view: T) {
            self.id = UUID().uuidString
            self.body = AnyView(view.id(self.id))
        }
        
        public var body: AnyView
    }
    
    init<L: View, T: View>(leading: L, trailing: T) {
        self.leading = .init(leading)
        self.trailing = .init(trailing)
    }
    
    init() {
        self.leading = .init(EmptyView())
        self.trailing = .init(EmptyView())
    }
    
    public let leading: Items
    public let trailing: Items
}

public extension View {

    /// Configures the navigation bar items for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - leading: A view that appears on the leading edge of the title.
    ///     - trailing: A view that appears on the trailing edge of the title.
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    func navigationBarButtonItems<L, T>(leading: L, trailing: T) -> some View where L : View, T : View {
        self.preference(key: NavigationBarButtonItemsPreferences.self, value: NavigationBarButtomItems(leading: leading, trailing: trailing))
        .navigationBarItems(leading: leading, trailing: trailing)
    }


    /// Configures the navigation bar items for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - leading: A view that appears on the leading edge of the title.
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    func navigationBarButtonItems<L>(leading: L) -> some View where L : View {
        self.preference(key: NavigationBarButtonItemsPreferences.self, value: NavigationBarButtomItems(leading: leading, trailing: EmptyView()))
        .navigationBarItems(leading: leading)
    }


    /// Configures the navigation bar items for this view.
    ///
    /// This modifier only takes effect when this view is inside of and visible
    /// within a `NavigationView`.
    ///
    /// - Parameters:
    ///     - trailing: A view shown on the trailing edge of the title.
    @available(OSX, unavailable)
    @available(watchOS, unavailable)
    func navigationBarButtonItems<T>(trailing: T) -> some View where T : View {
        self.preference(key: NavigationBarButtonItemsPreferences.self, value: NavigationBarButtomItems(leading: EmptyView(), trailing: trailing))
        .navigationBarItems(trailing: trailing)
    }
}

struct NavigationViewStyleKey: EnvironmentKey {
    static var defaultValue: AnyNavigationViewStyle?
}

public protocol NavigationViewStyle {
    
    associatedtype Body: View
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
    
    typealias Configuration = NavigationViewStyleConfiguration
}

extension EnvironmentValues {
    var navigationViewStyle: AnyNavigationViewStyle? {
        get { self[NavigationViewStyleKey.self] }
        set { self[NavigationViewStyleKey.self] = newValue }
    }
}

// MARK: - Environment Key

extension NavigationViewStyle {
    func makeBodyTypeErased(configuration: Self.Configuration) -> AnyView {
        AnyView(self.makeBody(configuration: configuration))
    }
}

public struct AnyNavigationViewStyle: NavigationViewStyle {
    private let _makeBody: (NavigationViewStyle.Configuration) -> AnyView
    
    public init<ST: NavigationViewStyle>(_ style: ST) {
        self._makeBody = style.makeBodyTypeErased
    }
    
    public func makeBody(configuration: NavigationViewStyle.Configuration) -> AnyView {
        return self._makeBody(configuration)
    }
}

public struct NavigationViewStyleConfiguration {
    public struct Content: View {
        init<V: View>(_ view: V) {
            self.body = AnyView(view)
        }
        
        public var body: AnyView
    }
    
    public struct BackgroundContent: View {
        
        init<V: View>(_ view: V) {
            self.body = AnyView(view)
        }
        
        public var body: AnyView
    }
    
    public let content: Content
    public let navigationBarItems: NavigationBarButtomItems
    public let navigationBarTitle: Text
    public let previousNavigationBarTitle: Text?
    public let navigationBarBackground: BackgroundContent
    public let navigationBarTintColor: Color
}

public struct SMNavigationViewStyle: SwiftUI.NavigationViewStyle, NavigationViewStyle {
    public func _body(configuration: _NavigationViewStyleConfiguration) -> some View {
        MorphNavigationView {
            configuration.content
        }
        .environment(\.navigationViewStyle, AnyNavigationViewStyle(self))
    }
    
    public init() {}
    
    public func makeBody(configuration: NavigationViewStyleConfiguration) -> some View {
        HostView(configuration: configuration)//HostView(configuration: configuration)
    }
    
    struct HostView: View {
        
        let configuration: NavigationViewStyleConfiguration
        
        @Environment(\.navigationStack) var navigationStack
        @Environment(\.verticalSizeClass) var verticalSizeClass
        
        var navigaitonButtonTransition: AnyTransition {
            return .asymmetric(insertion: AnyTransition.move(edge: .leading).combined(with: .opacity),
                               removal: AnyTransition.opacity)
        }
        
        var body: some View {
            
            let navigationBarHeight: CGFloat = self.verticalSizeClass == .regular ? 48 : 36
            
            return
                GeometryReader { container in
                    ZStack(alignment: .top) {
                        self.configuration.content
                            .offset(y: navigationBarHeight)
                        
                        VStack(spacing: 0) {
                            
                            Rectangle()
                                .fill(self.configuration.navigationBarTintColor.opacity(0.4))
                                .frame(height: container.safeAreaInsets.top)
                            
                            ZStack {
                                HStack {
                                    
                                    if self.navigationStack?.canPopUp == true {
                                        BackButton(previousTitle: self.configuration.previousNavigationBarTitle)
                                            .buttonStyle(NavigationBarButtonStyle(tintColor: self.configuration.navigationBarTintColor, isBackButton: true))
                                            .transition(.opacity)
                                    }
                                    
                                    self.configuration.navigationBarItems.leading
                                        .buttonStyle(NavigationBarButtonStyle(tintColor: self.configuration.navigationBarTintColor))
                                        .transition(.opacity)
                                    
                                    Spacer()
                                    
                                    self.configuration.navigationBarItems.trailing
                                        .buttonStyle(NavigationBarButtonStyle(tintColor: self.configuration.navigationBarTintColor))
                                        .transition(.opacity)
                                }
                                .padding(EdgeInsets(top: 0, leading: self.navigationStack?.canPopUp == true ? 8 : 16, bottom: 0, trailing: 16))
                                
                                HStack {
                                    Spacer()
                                    
                                    self.configuration.navigationBarTitle
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black, radius: 1, x: 0, y: -1)
                                        .font(.system(size: 20, weight: .bold))
                                        .transition(.slide)
                                    
                                    Spacer()
                                }
                                .padding(EdgeInsets(top: 0, leading: self.navigationStack?.canPopUp == true ? 8 : 16, bottom: 0, trailing: 16))
                                
                            }
                            .frame(height: navigationBarHeight)
                            .background(
                                GeometryReader { container in
                                    ZStack(alignment: .top) {
                                        Rectangle()
                                            .fill(self.configuration.navigationBarTintColor.opacity(0.5))
                                        
                                        LinearGradient(gradient: Gradient(colors: [
                                            Color.white.opacity(0.5),
                                            Color.clear
                                        ]), startPoint: .top, endPoint: .bottom)
                                        
                                        VStack(spacing: 0) {
                                            Rectangle()
                                                .fill(self.configuration.navigationBarTintColor.opacity(0.7))
                                                .frame(height: 0.5)
                                            
                                            Rectangle()
                                                .fill(Color.white)
                                                .frame(height: 0.5)
                                            
                                            Spacer()
                                            
                                            Rectangle()
                                                .fill(self.configuration.navigationBarTintColor)
                                                .frame(height: 0.5)
                                        }
                                    }
                                }
                                .edgesIgnoringSafeArea([.leading, .trailing])
                            )
                        }
                            .edgesIgnoringSafeArea(self.verticalSizeClass == .regular ? .top : .init())
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
        }
    }
}

struct AdditionalSafeAreaInsets: UIViewControllerRepresentable {
    
    let edgeInsets: EdgeInsets
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AdditionalSafeAreaInsets>) -> UIViewController {
        let vc = UIViewController()
        vc.additionalSafeAreaInsets = UIEdgeInsets(top: CGFloat(edgeInsets.top),
                                                   left: CGFloat(edgeInsets.leading),
                                                   bottom: CGFloat(edgeInsets.bottom),
                                                   right: CGFloat(edgeInsets.trailing))
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AdditionalSafeAreaInsets>) {
        uiViewController.additionalSafeAreaInsets = UIEdgeInsets(top: CGFloat(edgeInsets.top),
                                                                 left: CGFloat(edgeInsets.leading),
                                                                 bottom: CGFloat(edgeInsets.bottom),
                                                                 right: CGFloat(edgeInsets.trailing))
    }
}

struct BackButton: View {
    @Environment(\.navigationStack) private var navigationStack
    let previousTitle: Text?
    
    var body: some View {
        Button(action: {
            self.navigationStack?.pop()
        }, label: {
            self.previousTitle ?? Text("Назад")
        })
    }
}

struct NavigationBarButtonStyle: ButtonStyle {
    
    let tintColor: Color
    let isBackButton: Bool
    
    init(tintColor: Color, isBackButton: Bool = false) {
        self.tintColor = tintColor
        self.isBackButton = isBackButton
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(EdgeInsets(top: 6, leading: self.isBackButton ? 16 : 6, bottom: 6, trailing: self.isBackButton ? 8 : 6))
            .foregroundColor(Color.white)
            .font(.system(size: 15, weight: .semibold))
            .shadow(color: Color.black, radius: 1, x: 0, y: -1)
            .background(configuration.isPressed ? self.tintColor.opacity(0.7) : self.tintColor.opacity(0.2))
            .clipShape(ButtonShape(isBackButton: self.isBackButton))
            .overlay(
                ZStack {
                    ButtonShape(isBackButton: self.isBackButton)
                        .stroke(Color.black, lineWidth: 1)
                        .offset(y: 1)
                        .blur(radius: 1)
                    
                    ButtonShape(isBackButton: self.isBackButton)
                        .stroke(Color.black.opacity(0.5), lineWidth: 1)
                    
                }
            .mask(ButtonShape(isBackButton: self.isBackButton))
        )
            .animation(.linear(duration: 0.1))
            .shadow(color: Color.white.opacity(0.5), radius: 1, x: 0, y: 1)
    }
    
    struct ButtonShape: Shape {
            
            let isBackButton: Bool
            
            func path(in rect: CGRect) -> Path {
                
                let middleHeight = rect.height / 2
                let spacing: CGFloat = 12

                return Path { (path) in
                    if !self.isBackButton {
                        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 8, height: 8))
                    } else {
                        path.addLines([
                            CGPoint(x: rect.width, y: 0),
                            CGPoint(x: spacing, y: 0),
                            CGPoint(x: 0, y: middleHeight),
                            CGPoint(x: spacing, y: rect.height),
                            CGPoint(x: rect.width, y: rect.height),
                            CGPoint(x: rect.width, y: 0)
                        ])
                    }
                }
            }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension Color {
//    public static let primary: Color
    
    var uiColor: UIColor? {
        switch self {
        case .black: return .black
        case .white: return .white
        case .clear: return .clear
        case .blue: return .blue
        case .yellow: return .yellow
        case .gray: return .gray
        case .green: return .green
        case .pink: return .systemPink
        case .secondary: return .secondarySystemFill
        case .orange: return .orange
        case .purple: return .purple
        case .red: return .red
        default:
            return UIColor(hex: self.description)
        }
    }
}
