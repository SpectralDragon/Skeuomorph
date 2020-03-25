//
//  NavigationStyle.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/21/20.
//

import SwiftUI
import Morph

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

public struct SMNavigationViewStyle: SwiftUI.NavigationViewStyle, Morph.NavigationViewStyle {
    public func _body(configuration: _NavigationViewStyleConfiguration) -> some View {
        MorphNavigationView {
            configuration.content
        }
        .environment(\.navigationViewStyle, AnyNavigationViewStyle(self))
    }
    
    public init() {}
    
    public func makeBody(configuration: NavigationViewStyleConfiguration) -> some View {
        HostView(configuration: configuration)
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
