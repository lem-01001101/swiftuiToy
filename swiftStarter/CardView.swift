//
//  CardView.swift
//  swiftStarter
//
//  Created by Magtibay , Leo Jacinto  Malaluan on 6/12/24.
//

import SwiftUI

struct CardView: View {
    var card: Card = cards[0] 
    @Binding var screenSize: CGSize
    @State var isTapped = false
    @State var time = Date.now
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isActive = false
    @State var isDownloading = false
    let startDate = Date()
    @State var hasSimpleWave = false
    @State var hasComplexWave = false
    @State var hasPattern = false
    @State var hasNoise = false
    @State var hasEmboss = false
    @State var isPixellated = false
    @State var number: Float = 0
    let numberTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var isIncrementing = true
    
    struct AnimationValues {
        var position = CGPoint(x: 0, y: 0)
        var scale = 1.0
        var opacity = 0.0
    }
    
    var body: some View {
        TimelineView(.animation) { context in
            layout
                .frame(maxWidth: screenSize.width)
            .dynamicTypeSize(.xSmall ... .xLarge)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 10)
            .background(.blue.opacity(0.001))
            .if(hasSimpleWave, transform: { view in
                view.distortionEffect(ShaderLibrary.simpleWave(.float(startDate.timeIntervalSinceNow)), maxSampleOffset: CGSize(width: 100, height: 100), isEnabled: hasSimpleWave)
            })
            .if(hasComplexWave, transform: { view in
                    view.visualEffect { content, proxy in
                        content.distortionEffect(ShaderLibrary.complexWave(
                            .float(startDate.timeIntervalSinceNow),
                            .float2(proxy.size),
                            .float(0.5),
                            .float(8),
                            .float(10)
                        ), maxSampleOffset: CGSize(width: 100, height: 100), isEnabled: hasComplexWave)
                    }
                })
        }
    }
    
    var layout: some View {
        ZStack {
            TimelineView(.animation){ context in
                card.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: isTapped ? screenSize.height - 280: 500)
                    .frame(width: isTapped ? screenSize.width : screenSize.width - 40)
                    .if(hasPattern, transform: {view in
                        view.colorEffect(ShaderLibrary.circleLoader(.boundingRect, .float(startDate.timeIntervalSinceNow)), isEnabled: hasPattern)
                    })
                    .if(hasNoise, transform: { view in
                            view.overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .colorEffect(ShaderLibrary.noise(.float(startDate.timeIntervalSinceNow)), isEnabled: hasNoise)
                                    .blendMode(.overlay)
                                    .opacity(hasNoise ? 1 : 0)
                            )
                    })
                    .if(hasEmboss, transform: {view in
                        view.layerEffect(ShaderLibrary.emboss(.float(number)), maxSampleOffset: .zero, isEnabled: hasEmboss)
                    })
                    .if(isPixellated, transform: {view in
                            view.layerEffect(ShaderLibrary.pixellate(.float(number)), maxSampleOffset: .zero, isEnabled: isPixellated)
                    })
                    .onReceive(numberTimer, perform: { _ in
                        guard isPixellated || hasEmboss else { return }
                        /*
                        if isIncrementing {
                            number += 1
                        } else {
                            number -= 1
                        }
                        if number >= 10 {
                            isIncrementing = false
                        }
                        if number <= 0 {
                            isIncrementing = true
                         }*/
                        number += isIncrementing ? 1 : -1
                        isIncrementing = number >= 10 ? false : (number <= 0 ? true : isIncrementing)
                    })
                    .overlay(
                        Text(card.title)
                            .font(.system(size: isTapped ? 80: 17))
                            .foregroundStyle(.white)
                            .fontWeight(isTapped ? .heavy : .semibold)
                            .padding()
                            .shadow(color: .black, radius: isTapped ? 100 : 10, y:10)
                            .frame(maxHeight: .infinity, alignment: isTapped ? .center : .top)
                    )
                    .cornerRadius(isTapped ? 40 : 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(linearGradient)
                            .opacity(isTapped ? 0 : 1)
                    )
                    .offset(y: isTapped ? -200 : 0)
                    .phaseAnimator([1,2], trigger: isTapped ,content: { content, phase in
                        content.scaleEffect(phase == 2 ? 1.1 : 1)
                    })
                    .onTapGesture {
                        hasNoise.toggle()
                    }
            }
            
            
            Circle()
                .fill(.thinMaterial)
                .frame(width: 100)
                .overlay(Circle().stroke(.secondary))
                .overlay(Image(systemName: "photo").font(.largeTitle))
                .keyframeAnimator(initialValue: AnimationValues(), trigger: isDownloading)
            { content, value in
                content.offset(x: value.position.x, y: value.position.y)
                    .scaleEffect(value.scale)
                    .opacity(value.opacity)
            } keyframes: { value in
                KeyframeTrack(\.position){
                    SpringKeyframe(CGPoint(x:100, y:-100),
                                   duration: 0.5, spring: .bouncy)
                    CubicKeyframe(CGPoint(x:400, y:1000),
                                  duration: 0.5)
                }
                KeyframeTrack(\.scale){
                    CubicKeyframe(1.2, duration: 0.5)
                    CubicKeyframe(1, duration: 0.5)
                }
                KeyframeTrack(\.opacity){
                    CubicKeyframe(1, duration: 0)
                }
            }
            
            content
                .padding(20)
                .background(hasSimpleWave || hasComplexWave ? AnyView(Color(.secondarySystemBackground)) : AnyView(Color.clear.background(.regularMaterial)))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(linearGradient)
                )
                .cornerRadius(20)
                .padding(40)
                .background(.blue.opacity(0.001))
                .offset(y: isTapped ? 220 : 80)
                .phaseAnimator([1, 1.1], trigger: isTapped) { content, phase in
                    content.scaleEffect(phase)
                        .blur(radius: phase == 1.1 ? 20 : 0)
                } animation: { phase in
                    switch phase {
                    case 1: .bouncy
                    case 1.1: .easeOut(duration: 1)
                    default: .easeInOut
                    }
                }
            
            play
                .frame(width: isTapped ? 220 : 50)
                .if(hasPattern) { view in
                        view.foregroundStyle(
                            ShaderLibrary.angledFill(
                                .float(10),
                                .float(10),
                                .color(.blue)
                            )
                        )
                }
                .font(.largeTitle)
                .padding(20)
                .background(hasSimpleWave || hasComplexWave ? AnyView(Color(.secondarySystemBackground)) : AnyView(Color.clear.background(.ultraThinMaterial)))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(linearGradient)
                )
                .cornerRadius(20)
                .offset(y: isTapped ? 40 : -44)
        }
    }
    
    var linearGradient: LinearGradient {
        LinearGradient(colors: [.clear,
                                .primary.opacity(0.3), .clear],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var content: some View {
        VStack (alignment: .center) {

            Text(card.text)
                .font(.subheadline)
            HStack(spacing: 8.0) {
                VStack(alignment: .leading) {
                    Text("Size")
                        .foregroundColor(.secondary)
                    Text("1024x1024")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                Divider()
                VStack(alignment: .leading) {
                    Text("Type")
                        .foregroundColor(.secondary)
                    Text("Upscale")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                Divider()
                VStack(alignment: .leading) {
                    Text("Date")
                        .foregroundColor(.secondary)
                    Text("Today 5:19")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
            }
            .frame(height: /*@START_MENU_TOKEN@*/44.0/*@END_MENU_TOKEN@*/)
                            
            HStack {
                HStack {
                    Button { hasPattern.toggle() } label: {
                        Image(systemName: "ellipsis")
                            .symbolEffect(.pulse)
                    }
                    Divider()
                    Image(systemName: "sparkle.magnifyingglass")
                        .symbolEffect(.scale.up, isActive: isActive)
                        .onTapGesture { hasSimpleWave.toggle() }
                    Divider()
                    Image(systemName: "face.smiling")
                        .symbolEffect(.appear, isActive: isActive)
                        .onTapGesture { hasComplexWave.toggle() }
                }
                .padding()
                .frame(height: 44)
                .overlay(
                    UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                        topLeading: 0, bottomLeading: 20, bottomTrailing: 0, topTrailing: 20
                    ))
                    .strokeBorder(linearGradient)
                )
                .offset(x: -20, y: 20)
                
                Spacer()
                Image(systemName: "square.and.arrow.down")
                    .padding()
                    .frame(height: 44)
                    .overlay(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                            topLeading: 20, bottomLeading: 0, bottomTrailing: 20, topTrailing: 0
                        ))
                        .strokeBorder(linearGradient)
                    )
                    .offset(x: 20, y: 20)
                    .symbolEffect(.bounce, value: isDownloading)
                    .onTapGesture {
                        isDownloading.toggle()
                    }
            }
        }
    }
    
    var play: some View {
        HStack(spacing: 30) {
            Image(systemName: "wand.and.rays")
                .frame(width:44)
                .symbolEffect(.variableColor.iterative.reversing, options: .speed(3))
                .symbolEffect(.bounce, value: isTapped)
                .opacity(isTapped ? 1 : 0)
                .blur(radius: isTapped ? 0 : 20)
                .onTapGesture { hasEmboss.toggle() }
            Image(systemName: isTapped ? "pause.fill" : "play.fill")
                .frame(width:44)
                .contentTransition(.symbolEffect(.replace))
                .onTapGesture {
                    withAnimation(.bouncy){
                        isTapped.toggle()
                    }
                }
            Image(systemName: "bell.and.waves.left.and.right.fill")
                .frame(width:44)
                .symbolEffect(.bounce, options:.speed(3).repeat(3),value: isTapped)
                .opacity(isTapped ? 1 : 0)
                .blur(radius: isTapped ? 0 : 20)
                .onReceive(timer) { value in
                    time = value
                    isActive.toggle()
                }
                .onTapGesture { isPixellated.toggle() }
        }

    }
}

#Preview {
    CardView(screenSize: .constant(CGSize(width: 393, height: 852)))
}
