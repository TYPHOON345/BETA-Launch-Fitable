//
//  AnalyticsWidgets.swift
//  Fitable
//
//  Created by Kiran Lim on 9/8/22.
//

import Foundation
import RealmSwift
import SwiftUI
import Charts
import FirebaseAuth
import HealthKit


struct AnimatedChart: View {
    @Binding var DaySelected: Days
    @State var currentActiveItem: Hour?
    
    @State var plotWidth: CGFloat = 0
    var body: some View {
        
        Chart {
            ForEach(DaySelected.calorieshour){caloryhour in
                LineMark(
                    x: .value("Hour", caloryhour.hour),
                    y: .value("Calories", caloryhour.animate ? caloryhour.calories : 0)
                )
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")]), startPoint: .leading, endPoint: .trailing))
                .interpolationMethod(.catmullRom)
                
                if let currentActiveItem, currentActiveItem.id == caloryhour.id {
                    RuleMark(x: .value("Hour", currentActiveItem.hour))
                        .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                        .offset(x: (plotWidth / CGFloat(DaySelected.calorieshour.count)) / 2)
                        .annotation(position: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Calories Burnt")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(currentActiveItem.calories)")
                                    .font(.title3.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                        }
                }
            }
        }
        .chartOverlay(content: { ChartProxy in
            GeometryReader{innerproxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(DragGesture()
                        .onChanged {value in
                            let location = value.location
                            
                            if let hour: String = ChartProxy.value(atX: location.x) {
                                if let currentItem = DaySelected.calorieshour.first(where: {item in
                                    item.hour == hour
                                }) {
                                    self.currentActiveItem = currentItem
                                }
                            }
                        }
                        .onEnded({ value in
                            self.currentActiveItem = nil
                            self.plotWidth = ChartProxy.plotAreaSize.width
                        })
                    )
            }
        })
        .frame(width: 315, height: 200)
        .onChange(of: DaySelected, perform: { newvalue in
            animateGraph(fromChange: true)
        })
        .onAppear() {
            animateGraph()
        }
        
    }
    
    func animateGraph(fromChange: Bool = false) {
        for (index, _ ) in DaySelected.calorieshour.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                withAnimation(.interactiveSpring(response: 0.8,dampingFraction: 0.8, blendDuration: 0.8)) {
                    try! userdata.realm.write {
                        DaySelected.calorieshour[index].animate = true
                    }
                }
            }
        }
    }
}


struct caloriesWidget: View {
    @Binding var userdatafile: User
    @Binding var calories: Int
    @State var progress: CGFloat = 0
    @State var startAnimation: CGFloat = 0
    @State var size: CGSize
    var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(.systemGray5).opacity(0.75))
                if calories > 0 {
                    Circle()
                        
                        .strokeBorder(Color(.systemPurple), lineWidth: 5)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(.systemBackground))
                        .padding(20)
                    liquidWave(progress: progress, waveheight: 0.1, offset: startAnimation)
                        .fill(Color(.systemPurple))
                        .mask {
                            Circle()
                                .aspectRatio(contentMode: .fit)
                                .padding(10)
                        }
                        .padding(20)
                    VStack {
                        Text("Calories")
                            .font(.custom("Gotham Regular", size: 15))
                        Text("\(calories)")
                            .font(.custom("Gotham-Bold", size: 20))
                        Text("\(Int(progress * 100))%")
                            .font(.custom("GothamMedium", size: 15))
                        
                    }
                }
                else {
                    Text("No calories burned")
                        .font(.custom("GothamMedium", size: 15))
                }
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    startAnimation = size.width
                }
                
                progress = CGFloat(calories) / CGFloat(userdatafile.caloriesgoal)
            }
            .frame(width: size.width * 0.4, height: size.width * 0.4)
        
        .onAppear {
            
            if calories != 0 && userdatafile.caloriesgoal != 0 {
                self.progress = CGFloat(calories / userdatafile.caloriesgoal)
            }
        }
    }
    
}

struct liquidWave: Shape {
    var progress: CGFloat
    var waveheight: CGFloat
    var offset: CGFloat
    var animatableData: CGFloat {
        get{offset}
        set{offset = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        return Path {path in
            path.move(to: .zero)
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height = waveheight * rect.height
            
            for value in stride(from: 0, through: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            //Bottom portion
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}


struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    var text: String
}
struct PieSliceView: View {
    var pieSliceData: PieSliceData

    
    var midRadians: Double {
        return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
        
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    
                    let center = CGPoint(x: (width * 0.5), y: height * 0.5)
                    
                    path.move(to: center)
                    
                    path.addArc(
                        center: center,
                        radius: width * 0.5,
                        startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                        endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                        clockwise: false)
                    
                }
                .fill(pieSliceData.color)
                
                Text(pieSliceData.text)
                    .position(
                        x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.8 * cos(self.midRadians)),
                        y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.8 * sin(self.midRadians))
                    )
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct PieChartView: View {
    @State var values: [Float] = []
    public var colors: [Color]
    @State var names: [String] = []
    public var innerRadiusFraction: CGFloat = 0.7
    public var widthFraction: CGFloat = 0.75
    @State var geometry: CGSize
    @Binding var Dayselected: Days
    @State private var activeIndex: Int = -1
    
    @State var userdatafile: User = User(username: "", Email: "", Joindate: "", Userleague: .bronze)
    @Environment(\.colorScheme) var colourScheme
    public var backgroundColor: Color = Color(.systemGray5)
    public let formatter: (Double) -> String
    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []
        
        for (i, value) in values.enumerated() {
            let degrees: Double = Double(value * 360 / sum)
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), color: self.colors[i], text: String(format: "%.0f%%", value * 100 / sum)))
            endDeg += degrees
        }
        return tempSlices
    }
    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(self.backgroundColor)
                if values.count != 0 {
                    HStack(spacing: 20) {
                        ZStack{
                            ForEach(0..<self.values.count){ i in
                                PieSliceView(pieSliceData: self.slices[i])
                                    
                                    .scaleEffect(self.activeIndex == i ? 1.03: 1)
                                    .animation(.spring(), value: self.activeIndex)
                            }
                            .animation(.easeInOut(duration: 1), value: self.values)
                            .frame(width: (geometry.width * 0.5).rounded(.down), height: (geometry.width * 0.5).rounded(.down))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let radius = 0.5 * widthFraction * geometry.width
                                        let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                                        let dist = pow(pow(diff.x, 2.0) + pow(diff.y, 2.0), 0.5)
                                        if (dist > radius || dist < radius * innerRadiusFraction) {
                                            self.activeIndex = -1
                                            return
                                        }
                                        var radians = Double(atan2(diff.x, diff.y))
                                        if (radians < 0) {
                                            radians = 2 * Double.pi + radians
                                        }
                                        
                                        for (i, slice) in slices.enumerated() {
                                            if (radians < slice.endAngle.radians) {
                                                self.activeIndex = i
                                                break
                                            }
                                        }
                                    }
                                    .onEnded { value in
                                        self.activeIndex = -1
                                    }
                            )
                            
                            Circle()
                                .fill(self.backgroundColor)
                                .frame(width: geometry.width * 0.5 * self.innerRadiusFraction, height: geometry.width * 0.5 * self.innerRadiusFraction)
                            VStack {
                                
                                Text(self.activeIndex == -1 ? "Total" : names[self.activeIndex])
                                    .font(.title)
                                    .foregroundColor(Color.gray)
                                Text(self.formatter(Double(self.activeIndex == -1 ? values.reduce(0, +) : values[self.activeIndex])))
                                    .foregroundColor(self.colourScheme == .dark ? .white : .black)
                                    .font(.title)
                            }
                        }
                        PieChartRows(colors: self.colors, names: self.names, values: self.values.map { String($0) }, percents: self.values.map { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
                            .padding([.trailing, .top])
                    }
                }
                else {
                    Text("No Activity recorded that day")
                }
                
            }
        
        .frame(height: 250)
        .padding(.horizontal)
        
        .onAppear() {
            print("Dayselected Exercises: \(Dayselected.calories)")
            for exercise in Dayselected.exercises {
                let firstindex = names.firstIndex(where: {$0 == exercise.name})
                
                if firstindex != nil {
                    self.values[firstindex!] += exercise.timespent
                }
                else {
                    names.append(exercise.name)
                    values.append(exercise.timespent)
                }
            }
                
        }
        
    }
    
    
}

struct PieChartRows: View {
    var colors: [Color]
    var names: [String]
    var values: [String]
    var percents: [String]
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack{
                ForEach(0..<self.values.count){ i in
                    HStack {
                        RoundedRectangle(cornerRadius: 5.0)
                            .fill(self.colors[i])
                            .frame(width: 20, height: 20)
                        Text(self.names[i])
                            .foregroundColor(self.colorScheme == .dark ? .white : .black)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(self.values[i])
                                .foregroundColor(self.colorScheme == .dark ? .white : .black)
                            Text(self.percents[i])
                                .foregroundColor(Color.gray)
                        }
                    }
                }
            }
        }
    }
}

struct HeartRateWidget: View {
    @Binding var Dayselected: Days
    @State var progress: Float = 0.0
    @Binding var userdatafile: User
    
    @State var geo: CGSize
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(.systemGray5).opacity(0.75))
                if Dayselected.HeartRate != 0 {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 15.0)
                            .opacity(0.20)
                            .foregroundColor(Color.gray)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(.red)
                            .rotationEffect(Angle(degrees: 270))
                            .animation(.easeInOut(duration: 1.0), value: self.progress)
                    }.padding(.all, 15)
                    
                    VStack {
                        Text("\(Dayselected.HeartRate)")
                            .font(.custom("GothamMedium", size: 35))
                        Text("bpm")
                            .font(.custom("Gotham Regular", size: 25))
                            .opacity(0.75)
                    }
                }
                else {
                    Text("No Activity")
                        .font(.custom("GothamMedium", size: 25))
                }
                
            }
            .frame(width: (geo.width * 0.4), height: (geo.width * 0.4))
    
        
        .onAppear() {
            if Dayselected.HeartRate != 0 && userdatafile.HeartrateGoal != 0 {
                self.progress = Float(Dayselected.HeartRate) / Float(userdatafile.HeartrateGoal)
            }
        }
    }
}

struct StepsWidget: View {
    @State var progress: Float = 0.0
    
    @State var steps: Float = 0
    @State var stepsGoal: Float = 10000
    
    @Binding var dayselected: Days
    @Binding var userdatafile: User
    //MARK: Animation Properties
    @State var animationRange: [Int] = []
    
    @State var geo: CGSize
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .frame(minWidth: (geo.width * 0.4).rounded(.down), minHeight: (geo.width * 0.5).rounded(.down))
                    .foregroundColor(Color(.systemGray5))
                if self.progress != 0.0 {
                    VStack(alignment: .leading) {
                        Text("Steps")
                            .font(.custom("Gotham Regular", size: 25))
                            .padding(.leading)
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 15.0)
                                .opacity(0.20)
                                .foregroundColor(Color.gray)
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                                .foregroundColor(.green)
                                .rotationEffect(Angle(degrees: 270))
                                .animation(.easeInOut(duration: 1.0), value: self.progress)
                            VStack {
                                //MARK: Rolling counter for steps
                                HStack(spacing: 0) {
                                    ForEach(0..<animationRange.count, id: \.self) {index in
                                        Text("8")
                                            .font(.custom("GothamMedium", size: 35))
                                            .opacity(0)
                                            .overlay {
                                                GeometryReader {proxy in
                                                    let size = proxy.size
                                                    VStack(spacing: 0) {
                                                        ForEach(0...9, id: \.self) {number in
                                                            Text("\(number)")
                                                                .font(.custom("GothamMedium", size: 35))
                                                        }
                                                    }
                                                    .offset(y: -CGFloat(self.animationRange[index]) * size.height)
                                                }
                                                .clipped()
                                            }
                                    }
                                }
                                Text("Steps")
                                    .font(.custom("Gotham Regular", size: 20))
                            }
                        }.padding(.all, 15)
                    }
                }
                else {
                    Text("No Steps recorded")
                        .font(.custom("GothamMedium", size: 25))
                }
            }
            .frame(width: (geo.width * 0.4).rounded(.down), height: (geo.width * 0.4).rounded(.down))
        
        .onAppear() {
            if dayselected.steps != 0 && userdatafile.StepsGoal != 0 {
                self.steps = dayselected.steps
                self.stepsGoal = userdatafile.StepsGoal
                self.progress = self.steps / self.stepsGoal
                animationRange = Array(repeating: 0, count: "\(Int(self.steps))".count)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06){
                    updateText()
                }
            }
        }
        .onChange(of: self.steps) { newValue in
            let extra = "\(self.steps)".count - animationRange.count
            if extra > 0 {
                for _ in 0..<extra {
                    withAnimation(.easeIn(duration: 0.1)) {
                        self.animationRange.append(0)
                    }
                }
            }else {
                for _ in 0..<(-extra) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        self.animationRange.removeLast()
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                updateText()
            }
            
        }
        
        
    }
    
    func updateText() {
        let StringValue = "\(Int(self.steps))"
        for (index, value) in zip(0..<StringValue.count, StringValue) {
            var fraction = Double(index) * 0.15
            fraction = (fraction > 0.5 ? 0.5 : fraction)
            withAnimation(.interactiveSpring(response: 1, dampingFraction: 1, blendDuration: 1 + fraction)) {
                animationRange[index] = (String(value) as NSString).integerValue
                
            }
        }
    }
}

