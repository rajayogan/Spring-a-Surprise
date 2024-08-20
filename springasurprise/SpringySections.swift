//
//  SpringySections.swift
//  springasurprise
//
//  Created by Raja Yogan on 19/08/24.
//

import SwiftUI

struct SpringySections: View {
    
    @State private var whiteValue = 50.0
    @State private var pinkValue = 50.0
    
    @State var tickColor = 7.0
    
    let ticks: [Tick] = [.major, .mid, .minor, .minor, .minor, .minor, .minor, .minor, .minor, .minor, .minor, .minor, .mid, .major]
    
    let maxHeight: CGFloat = UIScreen.main.bounds.height
    let maxWidth: CGFloat = UIScreen.main.bounds.width
    
    @State var dragWhiteValue = CGSize(width: 450, height: 300)
    @State var changeToggle = false
    @State var currentWhiteValue = CGSize(width: 450, height: 300)
    
    //Pink box
    @State var dragPinkValue = CGSize(width: 450, height: 600)
    @State var changePinkToggle = false
    @State var currentPinkValue = CGSize(width: 450, height: 600)
    
    //Flags for first load
    @State var isFirstLoad: Bool = false
    @State var isFirstLoadWhite: Bool = false
    
    //Touch points
    @State var xTouchPoint = 0.0
    @State var yTouchPoint = 0.0
    @State var xTouchPointPink = 0.0
    @State var yTouchPointPink = 0.0
    
    //To disable the dragging gesture after a particular height on both sides
    @State var disableDragWhite = false
    @State var disableDragPink = false
    
    //To keep the current dragged section on top
    @State var whiteIndex = 0.0
    @State var pinkIndex = 1.0
    
    //To move overlays
    @State var overLayMovePink = 0.0
    @State var overLayMoveWhite = 0.0
    
    //To preserve overlayMoved position
    @State var accmPinkOverlay = 0.0
    @State var accmWhiteOverlay = 0.0
    
    
    var body: some View {
        ZStack {
            if(pinkIndex == 1.0) {
                Color.white.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            }
            else {
                Color.rajapink.edgesIgnoringSafeArea(.all)
            }
            
            WhiteBox(dragWhiteValue: dragWhiteValue.height, changeToggle: changeToggle, currentWhiteValue: currentWhiteValue.height, xTouchPoint: xTouchPoint, yTouchPoint: yTouchPoint)
                .fill(.white)
                .overlay(
                    HStack {
                        Text("\(Int(whiteValue))")
                            .font(.custom("Lato-Bold", size: Double(whiteValue) > 30 ? Double(whiteValue + 15) : 40))
                            .foregroundColor(.rajapink)
                        VStack(alignment: .leading) {
                            Text("POINTS")
                                .font(.custom("Lato-Bold", size: 15))
                                .foregroundColor(.rajapink)
                            Text("YOU NEED")
                                .font(.custom("Lato-Bold", size: 15))
                                .foregroundColor(.rajapink)
                        }
                    }.padding(.vertical, 15)
                        .padding(.horizontal, 55)
                        .offset(y: overLayMoveWhite)
                    , alignment: .topLeading
                )
                .gesture(DragGesture()
                    .onChanged({value in
                        if(whiteIndex == 0.0) {
                            accmWhiteOverlay = (maxHeight / 2) - (maxHeight / 4) - 75
                        }
                        //To bring this up (alternatively this will also make the bg color pink so that it looks like pink is edging into white when pulled up)
                        pinkIndex = 0.0
                        whiteIndex = 1.0
                        //This will trigger the curve in the path
                        if(!changeToggle) {
                            changeToggle.toggle()
                        }
                        
                        dragWhiteValue = CGSize(width: value.translation.height, height: value.translation.height + currentWhiteValue.height)
                        
                        //Move the overlay above or below a little as it increases in size
                        if(currentWhiteValue.height - dragWhiteValue.height < 0) {
                            overLayMoveWhite = accmWhiteOverlay + dragWhiteValue.height / 100
                            
                            overLayMovePink = accmPinkOverlay + dragWhiteValue.height / 50
                        }
                        else {
                            overLayMoveWhite = accmWhiteOverlay - dragWhiteValue.height / 100
                            
                            overLayMovePink = accmPinkOverlay - dragWhiteValue.height / 50
                        }
                        
                        xTouchPoint = value.location.x
                        yTouchPoint = value.location.y
                        
                        //For the overlay points
                        whiteValue = dragWhiteValue.height / (maxHeight / 100)
                        pinkValue = 101 - whiteValue
                    })
                        .onEnded({
                            value in
                            
                            var heightDiff = dragWhiteValue.height - currentWhiteValue.height
                            
                            withAnimation(.spring(duration: 0.2, bounce: 0.85)) {
                                currentWhiteValue = dragWhiteValue
                                dragWhiteValue = CGSize(width: currentWhiteValue.width, height: currentWhiteValue.height - 25)
                                
                                if(changeToggle) {
                                    changeToggle.toggle()
                                }
                            }
                            
                            dragWhiteValue = CGSize(width: currentWhiteValue.width, height: currentWhiteValue.height)
                            //Need to calculate this as well to increase decrease based on the other side
                            dragPinkValue = CGSize(width: currentPinkValue.width, height: currentPinkValue.height + heightDiff)
                            currentPinkValue = dragPinkValue
                            accmPinkOverlay = overLayMovePink
                            accmWhiteOverlay = overLayMoveWhite
                            //To change scale markings
                            
                            var tempDiff = 0.0
                            if(dragWhiteValue.height > (maxHeight / 2)) {
                                tempDiff = dragWhiteValue.height - (maxHeight / 2)
                                
                                tickColor = 7.0 + tempDiff / (maxHeight / 14)
                            }
                            else {
                                tempDiff =  (maxHeight / 2) - dragWhiteValue.height
                                
                                tickColor = 7.0 - tempDiff / (maxHeight / 14)
                            }
                            //Disable the drag gesture after a certain point
                            if(whiteValue < 30 || whiteValue > 80) {
                                disableDragPink = false
                                disableDragWhite = true
                            }
                            else {
                                disableDragWhite = false
                                disableDragPink = false
                            }
                        })
                )
                .disabled(disableDragWhite)
                .onAppear {
                    if(!isFirstLoadWhite) {
                        dragWhiteValue.height = maxHeight / 2
                        currentWhiteValue.height = maxHeight / 2
                        overLayMoveWhite = (maxHeight / 2) - (maxHeight / 4) - 75
                        accmWhiteOverlay = (maxHeight / 2) - (maxHeight / 4) - 75
                        isFirstLoadWhite.toggle()
                    }
                }
                .zIndex(whiteIndex)
            
            //Bottom box
            PinkBox(dragWhiteValue: dragPinkValue.height, changeToggle: changePinkToggle, currentWhiteValue: currentPinkValue.height, xTouchPoint: xTouchPointPink, yTouchPoint: yTouchPointPink)
                .fill(.rajapink)
                .overlay(
                    HStack {
                        Text("\(Int(pinkValue))")
                            .font(.custom("Lato-Bold", size: Double(pinkValue) > 30 ? Double(pinkValue + 15) : 40))
                            .foregroundColor(.white)
                        VStack(alignment: .leading) {
                            Text("POINTS")
                                .font(.custom("Lato-Bold", size: 15))
                                .foregroundColor(.white)
                            Text("YOU HAVE")
                                .font(.custom("Lato-Bold", size: 15))
                                .foregroundColor(.white)
                        }
                    }.padding(.vertical, 25)
                        .padding(.horizontal, 55)
                        .offset(y: overLayMovePink)
                    , alignment: .topLeading
                )
                .gesture(DragGesture()
                    .onChanged({value in
                        
                        if(pinkIndex == 0.0) {
                            accmPinkOverlay = (maxHeight / 2) + (maxHeight / 4) - 25
                        }
                        
                        pinkIndex = 1.0
                        whiteIndex = 0.0
                        
                        if(!changePinkToggle) {
                            changePinkToggle.toggle()
                        }
                        
                        dragPinkValue = CGSize(width: value.translation.width, height: value.translation.height + currentPinkValue.height)
                        pinkValue = 101 - (dragPinkValue.height / (maxHeight / 100))
                        
                            //Moving overlays
                        if(currentWhiteValue.height - dragPinkValue.height > 0) {
                            overLayMovePink = accmPinkOverlay - dragPinkValue.height / 100
                            overLayMoveWhite = accmWhiteOverlay - dragPinkValue.height / 100
                        }
                        else {
                            overLayMovePink = accmPinkOverlay + dragPinkValue.height / 100
                            overLayMoveWhite = accmWhiteOverlay + dragPinkValue.height / 100
                        }
                        
                        whiteValue = 101 - pinkValue
                        xTouchPointPink = value.location.x
                        yTouchPointPink = value.location.y
                    })
                        .onEnded({value in
                            var heightDiff = dragPinkValue.height - currentPinkValue.height
                            
                            withAnimation(.spring(duration: 0.2, bounce: 0.85)) {
                                currentPinkValue = dragPinkValue
                                
                                dragPinkValue = CGSize(width: currentPinkValue.width, height: currentPinkValue.height - 25)
                                if(changePinkToggle) {
                                    changePinkToggle.toggle()
                                }
                            }
                            
                            dragPinkValue = CGSize(width: currentPinkValue.width, height: currentPinkValue.height)
                            dragWhiteValue = CGSize(width: currentWhiteValue.width, height: currentWhiteValue.height + heightDiff)
                            currentWhiteValue = dragWhiteValue
                            accmPinkOverlay = overLayMovePink
                            accmWhiteOverlay = overLayMoveWhite
                            //To change scale markings color
                            var tempDiff = 0.0
                            if(dragPinkValue.height > (maxHeight / 2)) {
                                tempDiff = dragPinkValue.height - (maxHeight / 2)
                                tickColor = 7.0 + tempDiff / maxHeight / 14
                            }
                            else {
                                tempDiff = (maxHeight / 2) - dragPinkValue.height
                                tickColor = 7.0 - tempDiff / maxHeight / 14
                            }
                            
                            if(pinkValue < 30 || pinkValue > 80) {
                                disableDragPink = true
                                disableDragWhite = false
                            }
                            else {
                                disableDragPink = false
                                disableDragWhite = false
                            }
                        })
                         )
                .disabled(disableDragPink)
                .onAppear {
                    if(!isFirstLoad) {
                        dragPinkValue.height = maxHeight / 2
                        currentPinkValue.height = maxHeight / 2
                        overLayMovePink = (maxHeight / 2) +  (maxHeight / 4) - 25
                        accmPinkOverlay = overLayMovePink
                        
                        isFirstLoad.toggle()
                    }
                }
                .zIndex(pinkIndex)
            
                //Scale markings
            VStack(spacing: 32) {
                ForEach(1..<15) { num in
                    if(num <= 7) {
                        Unit(num: num, ticks: ticks[num - 1], tickColor: tickColor)
                            .stroke(num <= Int(tickColor) ? .rajapink: .white, lineWidth: 2)
                            .frame(height: 20)
                    }
                    else {
                        Unit(num: num, ticks: ticks[num - 1], tickColor: tickColor)
                            .stroke(num <= Int(tickColor) + 1 ? .rajapink: .white, lineWidth: 2)
                            .frame(height: 20)
                    }
                }
            }.padding(EdgeInsets(top: 85.0, leading: 1.0, bottom: 10.0, trailing: 4.0))
                .zIndex(2.0)
            
            //Header
            VStack {
                HStack {
                    Button(
                        action: {
                            
                        },
                        label: {
                            Image("menubutton")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 20, height : 20)
                                .foregroundColor(.rajapink)
                        }
                    )
                    Spacer()
                    Button(
                        action: {
                            
                        },
                        label: {
                            Text("SETTINGS")
                                .font(.custom("MontserratRoman-Bold", size: 15.0))
                                .foregroundColor(.rajapink)
                        }
                    )
                }
                .padding(EdgeInsets(top: 50.0, leading: 25.0, bottom: 2, trailing: 25))
                Spacer()
                HStack {
                    Button(
                        action: {
                            
                        },
                        label: {
                            Text("MORE")
                                .font(.custom("MontserratRoman-Bold", size: 15.0))
                                .foregroundColor(.white)
                        }
                    )
                    Spacer()
                    Button(
                        action: {
                            
                        },
                        label: {
                            Text("STATS")
                                .font(.custom("MontserratRoman-Bold", size: 15.0))
                                .foregroundColor(.white)
                        }
                    )
                }
                .padding(EdgeInsets(top: 2.0, leading: 25.0, bottom: 5.0, trailing: 25.0))
                
            }.zIndex(3)
        }.edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}

struct WhiteBox: Shape {
    
    var dragWhiteValue: CGFloat
    var changeToggle: Bool
    var currentWhiteValue: CGFloat
    
    var xTouchPoint: Double
    var yTouchPoint: Double
    let maxHeight: CGFloat = UIScreen.main.bounds.height
    let maxWidth: CGFloat = UIScreen.main.bounds.width
    
    var animatableData: CGFloat {
        get { dragWhiteValue }
        set { dragWhiteValue = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            //Left top point
            path.move(to: CGPoint(x: 0, y: 0))
            //Left edge
            path.addLine(to: CGPoint(x: 0, y: dragWhiteValue))
            
            //Curve
            if(changeToggle) {
                path.addQuadCurve(to: CGPoint(x: 0, y:currentWhiteValue), control: CGPoint(x: 0, y: currentWhiteValue))
                path.addQuadCurve(to: CGPoint(x: maxWidth, y:currentWhiteValue), control: CGPoint(x: xTouchPoint, y: yTouchPoint))
            }
            
            //Right edge
            path.addLine(to: CGPoint(x: maxWidth, y: dragWhiteValue))
            path.addLine(to: CGPoint(x: maxWidth, y: 0))
        }
    }
}

struct PinkBox: Shape {
    var dragWhiteValue: CGFloat
    var changeToggle: Bool
    var currentWhiteValue: CGFloat
    
    var xTouchPoint: Double
    var yTouchPoint: Double
    
    let maxHeight: CGFloat = UIScreen.main.bounds.height
    let maxWidth: CGFloat = UIScreen.main.bounds.width
    
    var animatableData: CGFloat {
        get { dragWhiteValue }
        set { dragWhiteValue = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: maxWidth, y: maxHeight))
            path.addLine(to: CGPoint(x: maxWidth, y: dragWhiteValue))
            
            //Curve
            if(changeToggle) {
                path.addQuadCurve(to: CGPoint(x: maxWidth, y: currentWhiteValue), control: CGPoint(x: maxWidth, y: currentWhiteValue))
                path.addQuadCurve(to: CGPoint(x: 0, y: currentWhiteValue), control: CGPoint(x: xTouchPoint, y: yTouchPoint))
            }
            
            path.addLine(to: CGPoint(x: 0, y: dragWhiteValue))
            path.addLine(to: CGPoint(x: 0, y: maxHeight))
        }
    }
}

struct Unit: Shape {
    let num: Int
    let ticks: Tick
    let tickColor: Double
    
    func path(in rect: CGRect) -> Path {
        let distance = rect.height / 14.0
        var path = Path()
        
        var y = rect.minY
        
        switch ticks {
        case .major:
            path.move(to: CGPoint(x: rect.maxX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX - 32, y: y))
            
        case .mid:
            path.move(to: CGPoint(x: rect.maxX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX - 24, y: y))
        case .minor:
            path.move(to: CGPoint(x: rect.maxX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX - 16, y: y))
        }
        
        y += distance
        return path
    }
}

enum Tick {
    case major, mid, minor
}
