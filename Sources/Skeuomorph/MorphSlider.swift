//
//  MorphSlider.swift
//  Skeuomorph
//
//  Created by v.prusakov on 3/14/20.
//

import SwiftUI
import Morph

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
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
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
