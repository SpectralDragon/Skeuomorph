//
//  SMSlider.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/14/20.
//

import SwiftUI

public struct SMSlider<Label: View, ValueLabel: View>: View {
    
    @Environment(\.sliderStyle) var style: AnySliderStyle
    
    let configuration: SliderStyleConfiguration
    
    public init(value: Binding<Float>,
                in bounds: ClosedRange<Float> = 0...1,
                step: Float = 0.01,
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                minimumValueLabel: ValueLabel,
                maximumValueLabel: ValueLabel,
                @ViewBuilder label: () -> Label) {
        
        let sliderLabel = SliderStyleConfiguration.Label(body: label())
        let minimumLabel = SliderStyleConfiguration.ValueLabel(body: minimumValueLabel)
        let maximumLabel = SliderStyleConfiguration.ValueLabel(body: maximumValueLabel)
        
        self.configuration = SliderStyleConfiguration(label: sliderLabel,
                                                      projectedValue: value,
                                                      minimumValueLabel: minimumLabel,
                                                      maximumValueLabel: maximumLabel,
                                                      bounds: bounds,
                                                      step: step,
                                                      onEditingChanged: onEditingChanged)
    }
    
    public var body: some View {
        return style.makeBody(configuration: self.configuration)
    }
}

extension SMSlider where ValueLabel == EmptyView {
    
    /// Creates an instance that selects a value from within a range.
    ///
    /// - Parameters:
    ///     - value: The selected value within `bounds`.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - onEditingChanged: A callback for when editing begins and ends.
    ///     - label: A `View` that describes the purpose of the instance.
    ///
    /// The `value` of the created instance will be equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// `onEditingChanged` will be called when editing begins and ends. For
    /// example, on iOS, a `Slider` is considered to be actively editing while
    /// the user is touching the knob and sliding it around the track.
    @available(tvOS, unavailable)
    public init(value: Binding<Float>, in bounds: ClosedRange<Float> = 0...1, onEditingChanged: @escaping (Bool) -> Void = { _ in }, @ViewBuilder label: () -> Label) {
        self = SMSlider(value: value,
                        in: bounds,
                        step: 0.01,
                        onEditingChanged: onEditingChanged,
                        minimumValueLabel: EmptyView(),
                        maximumValueLabel: EmptyView(),
                        label: label)
    }
    
    /// Creates an instance that selects a value from within a range.
    ///
    /// - Parameters:
    ///     - value: The selected value within `bounds`.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - step: The distance between each valid value.
    ///     - onEditingChanged: A callback for when editing begins and ends.
    ///     - label: A `View` that describes the purpose of the instance.
    ///
    /// The `value` of the created instance will be equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// `onEditingChanged` will be called when editing begins and ends. For
    /// example, on iOS, a `Slider` is considered to be actively editing while
    /// the user is touching the knob and sliding it around the track.
    @available(tvOS, unavailable)
    public init(value: Binding<Float>,
                in bounds: ClosedRange<Float>,
                step: Float = 1,
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                @ViewBuilder label: () -> Label) {
        self = SMSlider(value: value,
                        in: bounds,
                        step: step,
                        onEditingChanged: onEditingChanged,
                        minimumValueLabel: EmptyView(),
                        maximumValueLabel: EmptyView(),
                        label: label)
    }
}

@available(iOS 13.0, OSX 10.15, watchOS 6.0, *)
@available(tvOS, unavailable)
extension SMSlider where Label == EmptyView, ValueLabel == EmptyView {
    
    /// Creates an instance that selects a value from within a range.
    ///
    /// - Parameters:
    ///     - value: The selected value within `bounds`.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance will be equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// `onEditingChanged` will be called when editing begins and ends. For
    /// example, on iOS, a `Slider` is considered to be actively editing while
    /// the user is touching the knob and sliding it around the track.
    @available(tvOS, unavailable)
    public init(value: Binding<Float>,
                in bounds: ClosedRange<Float> = 0...1,
                onEditingChanged: @escaping (Bool) -> Void = { _ in }) {
        self = SMSlider(value: value,
                        in: bounds,
                        step: 0.01,
                        onEditingChanged: onEditingChanged,
                        minimumValueLabel: EmptyView(),
                        maximumValueLabel: EmptyView(),
                        label: { EmptyView() })
    }
    
    /// Creates an instance that selects a value from within a range.
    ///
    /// - Parameters:
    ///     - value: The selected value within `bounds`.
    ///     - bounds: The range of the valid values. Defaults to `0...1`.
    ///     - step: The distance between each valid value.
    ///     - onEditingChanged: A callback for when editing begins and ends.
    ///
    /// The `value` of the created instance will be equal to the position of
    /// the given value within `bounds`, mapped into `0...1`.
    ///
    /// `onEditingChanged` will be called when editing begins and ends. For
    /// example, on iOS, a `Slider` is considered to be actively editing while
    /// the user is touching the knob and sliding it around the track.
    @available(tvOS, unavailable)
    public init(value: Binding<Float>,
                in bounds: ClosedRange<Float>,
                step: Float = 1,
                onEditingChanged: @escaping (Bool) -> Void = { _ in }) {
        self = SMSlider(value: value,
                        in: bounds,
                        step: step,
                        onEditingChanged: onEditingChanged,
                        minimumValueLabel: EmptyView(),
                        maximumValueLabel: EmptyView(),
                        label: { EmptyView() })
    }
}


public struct SliderStyleConfiguration {
    
    /// A type-erased label of a `Toggle`.
    public struct Label : View {
        
        init<V: View>(body: V) {
            self.body = AnyView(body)
        }
        
        public var body: AnyView
        
        /// The type of view representing the body of this view.
        ///
        /// When you create a custom view, Swift infers this type from your
        /// implementation of the required `body` property.
        public typealias Body = AnyView
    }
    
    public struct ValueLabel : View {
        
        init<V: View>(body: V) {
            self.body = AnyView(body)
        }
        
        
        public var body: AnyView
        
        /// The type of view representing the body of this view.
        ///
        /// When you create a custom view, Swift infers this type from your
        /// implementation of the required `body` property.
        public typealias Body = AnyView
    }
    
    /// A view that describes the effect of slider `value`.
    public let label: SliderStyleConfiguration.Label
    
    public var value: Float {
        get { projectedValue.wrappedValue }
        nonmutating set { projectedValue.wrappedValue = newValue }
    }
    
    public let projectedValue: Binding<Float>
    
    public let minimumValueLabel: SliderStyleConfiguration.ValueLabel
    public let maximumValueLabel: SliderStyleConfiguration.ValueLabel
    
    public let bounds: ClosedRange<Float>
    
    public let step: Float
    
    public let onEditingChanged: (Bool) -> Void
}








// MARK: - Move to core -

/// Defines the implementation of all `Slider` instances within a view
/// hierarchy.
///
/// To configure the current `SliderStyle` for a view hiearchy, use the
/// `.sliderStyle()` modifier.
public protocol SliderStyle {
    
    associatedtype Body: View
    
    func makeBody(configuration: Self.Configuration) -> Self.Body
    
    typealias Configuration = SliderStyleConfiguration
    
}

// MARK: - Environment Key
extension EnvironmentValues {
    var sliderStyle: AnySliderStyle {
        get {
            return self[SliderStyleKey.self]
        }
        set {
            self[SliderStyleKey.self] = newValue
        }
    }
}

extension SliderStyle {
    func makeBodyTypeErased(configuration: Self.Configuration) -> AnyView {
        AnyView(self.makeBody(configuration: configuration))
    }
}

public struct SliderStyleKey: EnvironmentKey {
    public static let defaultValue: AnySliderStyle = AnySliderStyle(DefaultSliderStyle())
}

public struct AnySliderStyle: SliderStyle {
    private let _makeBody: (SliderStyle.Configuration) -> AnyView
    
    init<ST: SliderStyle>(_ style: ST) {
        self._makeBody = style.makeBodyTypeErased
    }
    
    public func makeBody(configuration: SliderStyle.Configuration) -> AnyView {
        return self._makeBody(configuration)
    }
}

public extension View {
    func sliderStyle<S: SliderStyle>(_ style: S) -> some View {
        self.environment(\.sliderStyle, AnySliderStyle(style))
    }
}


struct DefaultSliderStyle: SliderStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Slider(value: configuration.projectedValue,
               in: configuration.bounds,
               step: configuration.step,
               onEditingChanged: configuration.onEditingChanged,
               minimumValueLabel: configuration.minimumValueLabel,
               maximumValueLabel: configuration.maximumValueLabel,
               label: { configuration.label })
    }
}

public struct SkeuomorphSliderStyle: SliderStyle {
    
    public init() {}
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            
            configuration.minimumValueLabel
            
            InnerSlider(value: configuration.projectedValue,
                        bounds: configuration.bounds,
                        step: configuration.step,
                        onEditingChanged: configuration.onEditingChanged)
            
            configuration.maximumValueLabel
        }
    }
    
    struct InnerSlider<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        
        @Binding var value: V
        let bounds: ClosedRange<V>
        let step: V.Stride
        let onEditingChanged: (Bool) -> Void
        
        let progressHeight: CGFloat = 13
        
        @Environment(\.isEnabled) var isEnabled
        
        @State private var dragOffsetX: CGFloat? = nil
        
        var body: some View {
            
            ZStack(alignment: .leading) {
                GeometryReader { container in
                    ZStack(alignment: .leading) {
                        
                        // White background
                        Capsule()
                            .fill(Color(red: 247/255, green: 247/255, blue: 247/255))
                            .frame(width: container.size.width, height: self.progressHeight)
                        
                        // Progress bar
                        Capsule()
                            .fill(Color.accentColor)
                            .frame(width: container.size.width * CGFloat(self.value), height: self.progressHeight)
                        
                        // Slider shadow - stays still
                        Capsule()
                            .stroke(Color.black, lineWidth: 0.5)
                            .blur(radius: 0.5)
                            .frame(width: container.size.width, height: self.progressHeight)
                            .mask(
                                Capsule()
                                    .frame(width: container.size.width, height: self.progressHeight)
                        )
                            .overlay(
                                Capsule()
                                    .stroke(Color.gray, lineWidth: 3)
                                    .blur(radius: 1)
                                    .frame(width: container.size.width, height: self.progressHeight)
                                    .offset(y: 1.5)
                                    
                                    // Create a natural fall-off for the top shadow
                                    .mask(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(
                                                        colors: [Color.white, Color.black]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                        )
                                            .frame(width: container.size.width, height: self.progressHeight)
                                )
                                    // Set blend mode to multiply so the inner shadow reflects what color is underneath it
                                    .blendMode(.multiply)
                        )
                            .opacity(0.8)
                        
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(
                                    colors: [Color(red: 214/255, green: 213/255, blue: 211/255),
                                             Color(red: 252/255, green: 252/255, blue: 251/255)]),
                                startPoint: .top,
                                endPoint: .bottom
                                )
                        )
                            // Two layers of shadow
                            .shadow(radius: 2)
                            .shadow(radius: 0.5)
                            .overlay(
                                // Blur then mask a circular stroke view for the inner shadow/stroke effect
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .blur(radius: 0.5)
                                    // Hide the
                                    .mask(Circle())
                        )
                            
                            .frame(width: 26, height: 26)
                            .offset(x: container.size.width * CGFloat(self.value) - 26)
                            //                            .offset(x: self.isOn ? 30: -30)
                            
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        
                                        let bounds = CGFloat(self.bounds.lowerBound)...CGFloat(self.bounds.upperBound)
                                        
                                        let availableLength = container.size.width - 26
                                        
                                        if self.dragOffsetX == nil {
                                            let computedValueOffset = self.offsetFromCenterToValue(
                                                overallLength: availableLength,
                                                value: CGFloat(self.value),
                                                bounds: bounds
                                            )
                                            
                                            self.dragOffsetX = value.startLocation.x - computedValueOffset
                                        }
                                        
                                        let locationOffset = value.location.x - (self.dragOffsetX ?? 0)
                                        let relativeValue = self.relativeValueFrom(overallLength: availableLength, centerOffset: locationOffset)
                                        let computedValue = self.valueFrom(relativeValue: relativeValue, bounds: bounds, step: CGFloat(self.step))
                                        self.$value.wrappedValue = V(computedValue)
                                        self.onEditingChanged(true)
                                }
                                .onEnded { _ in
                                    self.dragOffsetX = nil
                                    self.onEditingChanged(false)
                                }
                        )
                    }
                }
            }
            .frame(height: 36)
            .drawingGroup()
            .opacity(isEnabled ? 1 : 0.5)
        }
        
        // MARK: HELPER
        
        // This code was taken from https://github.com/naohta/sliders/blob/master/Sources/Sliders/SliderMath.swift
        
        func relativeValueFrom(value: CGFloat, bounds: ClosedRange<CGFloat> = 0.0...1.0) -> CGFloat {
            let boundsLenght = bounds.upperBound - bounds.lowerBound
            return (value - bounds.lowerBound) / boundsLenght
        }
        
        func relativeValueFrom(overallLength: CGFloat, centerOffset: CGFloat) -> CGFloat {
            (centerOffset + (overallLength / 2)) / overallLength
        }
        
        func offsetFromCenterToValue(overallLength: CGFloat, value: CGFloat, bounds: ClosedRange<CGFloat> = 0.0...1.0, startOffset: CGFloat = 0, endOffset: CGFloat = 0) -> CGFloat {
            let computedRelativeValue = relativeValueFrom(value: value, bounds: bounds)
            let offset = (startOffset - ((startOffset + endOffset) * computedRelativeValue))
            return offset + (computedRelativeValue * overallLength) - (overallLength / 2)
        }
        
        /// Calculates value for relative point in bounds with step.
        /// Example: For relative value 0.5 in range 2.0..4.0 produces 3.0
        func valueFrom(relativeValue: CGFloat, bounds: ClosedRange<CGFloat> = 0.0...1.0, step: CGFloat = 0.001) -> CGFloat {
            let newValue = bounds.lowerBound + (relativeValue * (bounds.upperBound - bounds.lowerBound))
            let steppedNewValue = (round(newValue / step) * step)
            let validatedValue = min(bounds.upperBound, max(bounds.lowerBound, steppedNewValue))
            return validatedValue
        }
    }
}
