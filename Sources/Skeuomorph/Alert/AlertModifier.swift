//
//  AlertModifier.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/18/20.
//

import SwiftUI

struct StyleAlertModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    let alertContent: Alert
    
    func body(content: _ViewModifier_Content<StyleAlertModifier>) -> some View {
        InternalView(isPresented: $isPresented, alert: alertContent, content: content)
    }
    
    struct InternalView<Content: View>: View {
        
        @Binding var isPresented: Bool
        let alert: Alert
        let content: Content
        
        @Environment(\.alertStyle) var alertStyle
                
        var body: some View {
            let configuration = AlertStyleConfiguration(content: AlertStyleConfiguration.Content(content),
                                                        alert: alert,
                                                        isPresented: $isPresented)
            
            return self.alertStyle.makeBody(configuration: configuration)
        }
    }
    
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    
    /// Presents an alert.
    ///
    /// - Parameters:
    ///     - item: A `Binding` to an optional source of truth for the `Alert`.
    ///     When representing a non-nil item, the system uses `content` to
    ///     create an alert representation of the item.
    ///
    ///     If the identity changes, the system will dismiss a
    ///     currently-presented alert and replace it by a new alert.
    ///
    ///     - content: A closure returning the `Alert` to present.
    func alertWithStyle<Item>(item: Binding<Item?>, content: (Item) -> Alert) -> some View where Item : Identifiable {
        ZStack {
            if item.wrappedValue != nil {
                self.modifier(StyleAlertModifier(
                    isPresented: Binding(get: { item.wrappedValue != nil }, set: {
                        if $0 == false {
                            item.wrappedValue = nil
                        }
                    }).animation(),
                    alertContent: content(item.wrappedValue!)))
            } else {
                self
            }
        }
    }
    
    
    /// Presents an alert.
    ///
    /// - Parameters:
    ///     - isPresented: A `Binding` to whether the `Alert` should be shown.
    ///     - content: A closure returning the `Alert` to present.
    func alertWithStyle(isPresented: Binding<Bool>, content: () -> Alert) -> some View {
        self.modifier(StyleAlertModifier(isPresented: isPresented.animation(), alertContent: content()))
    }
    
}

public struct SMAlertStyle: AlertStyle {
    
    public init() {}
    
    private var transition: AnyTransition {
        
        let insertion = AnyTransition.opacity
            .combined(with: .scale)
            .animation(
                Animation
                    .spring(response: 0.25, dampingFraction: 0.3, blendDuration: 0.2)
                    .delay(0.1)
        )
        
        let removal = AnyTransition.opacity
            .animation(.linear(duration: 0.2))
        
        return .asymmetric(insertion: insertion, removal: removal)
        
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        GeometryReader { container in
            ZStack {
                if !configuration.isPresented {
                    configuration.content
                } else {
                    configuration.content
                        .accentColor(Color.gray)
                }
                
                if configuration.isPresented {
                    
                    Rectangle()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .opacity(0.4)
                        .mask(
                            self.holeShapeMask(in: container.frame(in: .global))
                                .fill(style: FillStyle(eoFill: true, antialiased: true))
                                .blur(radius: 120)
                    )
                        .transition(.opacity)
                        .animation(.linear(duration: 0.2))
                        .edgesIgnoringSafeArea(.all)
                }
                
                
                if configuration.isPresented {
                    VStack(spacing: 0) {
                        
                        // TODO: needs scroll for big text
                        configuration.alert.title
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3), radius: 0, x: 0, y: -1)
                            .padding(EdgeInsets(top: 20, leading: 8, bottom: 8, trailing: 8))
                        
                        configuration.alert.message
                            .foregroundColor(Color.white)
                            .padding([.leading, .trailing], 8)
                        
                        HStack {
                            configuration.alert.primaryButton.flatMap { self.button(configuration, button: $0) }
                            
                            
                            configuration.alert.secondaryButton.flatMap { self.button(configuration, button: $0) }
                        }
                        .padding(EdgeInsets(top: 16, leading: 8, bottom: 8, trailing: 8))
                    }
                    .frame(minWidth: 100, minHeight: 100)
                    .background(
                            ZStack(alignment: .top) {
                                LinearGradient(gradient: Gradient(
                                    colors: [
                                        Color(red: 43/255, green: 51/255, blue: 90/255, opacity: 0.9),
                                        Color(red: 37/255, green: 51/255, blue: 90/255, opacity: 0.9)
                                ]),
                                               startPoint: .top,
                                               endPoint: .bottom)
                                
                                Ellipse()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 70)
                                    .offset(y: -27)
                                    .blur(radius: 1)
                            }
                        .mask(
                            RoundedRectangle(cornerRadius: 12)
                        )
                        
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 2)
                    )
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 3)
                        .padding(.all, 32)
                        .transition(self.transition)
                }
            }
        }
    }
    
    func holeShapeMask(in rect: CGRect) -> Path {
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: rect))
        return shape
    }
    
    func button(_ configuration: Self.Configuration, button: Self.Configuration.Alert.Button) -> some View {
        Button(action: {
            configuration.$isPresented.wrappedValue = false
            button.action()
        }, label: {
            button.label
        })
            .buttonStyle(AlertButtonStyle(style: button.style))
    }
}

struct AlertButtonStyle: ButtonStyle {
    
    let style: AlertStyleConfiguration.Alert.Button.Style
    
    @Environment(\.selectionFeedbackGenerator) private var feedbackGenerator
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
        if configuration.isPressed {
            self.feedbackGenerator.selectionChanged()
        }
        
        return
            configuration.label
            .frame(minWidth: 0, maxWidth: .infinity, idealHeight: 36)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .semibold))
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3), radius: 0, x: 0, y: -1)
            .padding([.bottom, .top], 8)
            .background(
                GeometryReader { container in
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(self.backgroundColor(for: configuration))
                            .overlay(
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .offset(y: -(container.size.height / 2))
                                    .blur(radius: 1)
                        )
                        
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    }
                }
        )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.white.opacity(0.2), radius: 0, x: 0, y: 1)
    }
    
    func backgroundColor(for configuration: Self.Configuration) -> Color {
        switch style {
        case .default:
            return configuration.isPressed ? Color(red: 68/255, green: 74/255, blue: 92/255) : Color(red: 104/255, green: 113/255, blue: 139/255)
        case .cancel:
            return configuration.isPressed ? Color(red: 43/255, green: 43/255, blue: 43/255, opacity: 0.5) : Color(red: 43/255, green: 51/255, blue: 90/255, opacity: 0.5)
        case .destructive:
            return configuration.isPressed ? Color(red: 130/255, green: 28/255, blue: 18/255) : Color(red: 189/255, green: 40/255, blue: 28/255)
        }
    }
    
}

struct UISelectionFeedbackGeneratorKey: EnvironmentKey {
    static var defaultValue: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
}

extension EnvironmentValues {
    var selectionFeedbackGenerator: UISelectionFeedbackGenerator {
        get {
            let generator = self[UISelectionFeedbackGeneratorKey.self]
            generator.prepare()
            return generator
        }
        set { self[UISelectionFeedbackGeneratorKey.self] = newValue }
    }
}
