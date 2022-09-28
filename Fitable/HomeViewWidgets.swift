//
//  HomeView Widgets.swift
//  Fitable
//
//  Created by Kiran Lim on 28/8/22.
//

import Foundation
import SwiftUI
import Charts
import FirebaseAuth
import GameKit

struct Widget: View {
    @State var widgetType: String
    @State var id = UUID()
    @EnvironmentObject var appState: AppState
    var body: some View {
        switch widgetType {
        case "recommendation":
            recommendedExercise()
                .environmentObject(appState)
        case "leaderboard":
            LeaderboardWidget()
        case "createexercise":
            QuickWorkoutWidget()
                .environmentObject(appState)
            
        case "dailyquote":
            dailyQuote()
        default:
            Text("Unrecognised widget")
        }
    }
    
}
struct Activitywidget: View {
    
    @State var userdatafile: User
    @State var currentActiveItem: Days?
    @State var plotWidth: CGFloat = 0
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        ZStack {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(.systemGray6))
            }
            if colorScheme == .light {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(.white)
                    .shadow(color: Color(.systemGray2    ), radius: 6, x: 0, y: 5)
            }
            if userdatafile.ExerciseData.count != 0 {
                Chart {
                    ForEach(userdatafile.ExerciseData) { item in
                        
                        LineMark(x: .value("Day", item.day), y: .value("Calories Burnt", item.animate ? item.calories : 0)
                        )
                        .foregroundStyle(.linearGradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")], startPoint: .leading, endPoint: .trailing))
                        .interpolationMethod(.catmullRom)
                        
                        
                        
                        if let currentActiveItem, currentActiveItem.id == item.id {
                            RuleMark(x: .value("Day", currentActiveItem.day))
                                .offset(x: (plotWidth / CGFloat(userdatafile.ExerciseData.count)) / 2)
                                .annotation(position: .top) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Calories Burnt")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(currentActiveItem.calories)")
                                            .font(.title3.bold())
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical,4)
                                    .background {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(.white.shadow(.drop(radius: 2)))
                                    }
                                }
                            
                        }
                        
                    }
                }
                .chartOverlay(content: {proxy in
                    GeometryReader {innerProxy in
                        Rectangle()
                            .fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged{value in
                                        let location = value.location
                                        if let value: String = proxy.value(atX: location.x){
                                            if let currentItem = userdatafile.ExerciseData.first(where: {item in
                                                item.day == value
                                                
                                            }) {
                                                self.currentActiveItem = currentItem
                                            }
                                        }
                                    }.onEnded {value in
                                        self.currentActiveItem = nil
                                        self.plotWidth = proxy.plotAreaSize.width
                                    }
                            )
                    }
                })
                .frame(width: 320, height: 210)
                .onAppear {
                    animateGraph()
                }
            }
            else {
                Text("No Activity Recorded Yet")
                    .font(.custom("GothamMedium", size: 20))
            }
        }
    }
    func animateGraph(fromchange: Bool = false){
        for (index, _)in userdatafile.ExerciseData.enumerated(){
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    withAnimation(.easeInOut(duration: 0.5).delay(Double(index) * (fromchange ? 0.03 : 0.05))) {
                        try! userdata.realm.write {
                            userdatafile.ExerciseData[index].animate = true
                        }
                    }
                }
            }
    }
}

struct recommendedExercise: View {
    @State var recommendedExercise: [Exercises] = [.Squats, .JumpingJacks]
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(.systemGray6))
            }
            if colorScheme == .light {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(.white)
                    .shadow(color: Color(.systemGray2    ), radius: 6, x: 0, y: 5)
            }
            
            VStack(alignment: .leading) {
                Text("Next up on your plan")
                    .font(.custom("GothamMedium", size: 20))
                    .padding([.leading, .top],10)
                ForEach(recommendedExercise, id: \.self) {exercise in
                    HStack {
                        Image("\(exercise.rawValue)")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white))
                        VStack {
                            Text(exercise.rawValue)
                                .font(.custom("GothamMedium", size: 30))
                            Text(getexerciseinfo(exercisename: exercise.rawValue).exerciseType.rawValue)
                                .font(.custom("GothamRegular", size: 15))
                            
                        }
                        .padding(.horizontal, 40)
                        
                        Image(systemName: "chevron.right")
                            .padding(15)
                            .overlay(Circle()
                                .stroke(Color(.systemGray5), lineWidth: 2))
                        

                        
                        
                            
                        
                    }
                    .padding(.all, 5)
                    .overlay (RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray2) , lineWidth: 2))
                    .onTapGesture {
                        PoseEstimator.shared.chosenExercise = exercise.rawValue
                        PoseEstimator.shared.isworkout = false
                        appState.target = .PoseEstimation
                    }
                }.padding(.all, 5)
            }
        }.frame(width: 350, height: 210)
        
    }
    func getexerciseinfo(exercisename: String) -> Exercise{
        let exercise = exerciselist.first(where: {$0.name == exercisename})!
        return exercise
    }
}

struct Quote {
    var quote: String
    var author: String
    var date: String
    var category: String
}
struct dailyQuote: View {
    
    @State var quotes: [Quote] = [Quote]()
    @Environment(\.colorScheme) var colorScheme
    @State var quote: String = "Loading"
    @State var author: String = ""
    var body: some View {
        ZStack {
            
            ScrollView {
                VStack {
                    Text(quote)
                        .font(.custom("GothamMedium", size: 25))
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5647059082984924, green: 0.5647059082984924, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.5686274766921997, green: 0.8784313797950745, blue: 0.8156862854957581, alpha: 1))]), startPoint: .leading, endPoint: .trailing))
                    HStack {
                        Spacer()
                        Text("~\(author)")
                            .font(.custom("Gotham Regular", size: 15))
                            .foregroundColor(Color(#colorLiteral(red: 0.5647059082984924, green: 0.5647059082984924, blue: 1, alpha: 1)))
                    }
                }
            }
                .padding(.all)
        }.frame(width: 350, height: 200)
            .onAppear() {
                fetchQuoteJson()
            }
            .background {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(Color(.systemGray6))
                        .frame(maxHeight: 200)
                }
                if colorScheme == .light {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(maxHeight: 200)
                        .foregroundColor(.white)
                        .shadow(color: Color(.systemGray2), radius: 6, x: 0, y: 5)
                    
                }
            }
    }
    
    func fetchQuoteJson() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "quotes.rest"
        components.path = "/qod.json"
        
        let maxlengthparameter = URLQueryItem(name: "maxlength", value: "100")
        components.queryItems = [maxlengthparameter]
        if let url:URL = components.url {
            print("quote url: \(url)")
            URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in

                if let err = error {
                    print("error = \(err)")
                    return
                }

                if let data: Data = data {

                    let dict: [String: Any]

                    do {
                        try dict = JSONSerialization.jsonObject(with: data) as! [String: Any]
                    } catch {
                        fatalError("could not create dictionary: \(error)");
                    }

                    print("dict.count \(dict.count)")
                    dict.forEach {print("\t\($0.key): \($0.value)");}

                    let quotesJson: [String: Any] = dict["contents"] as! [String: Any]

                    let quotes2: [[String: Any]] = quotesJson["quotes"] as! [[String: Any]]

                    print("quotes2.count = \(quotes2.count)")
                    
                    for q in quotes2 {
                        let author: String = q["author"] as! String
                        print("author = \(author)")
                        
                        let quotOfTheDay: String = q["quote"] as! String
                        print("quotOfTheDay = \(quotOfTheDay)")
                        
                        let category: String = q["category"] as! String
                        print("category = \(category)")
                        
                        let date: String = q["date"] as! String
                        print("date = \(date)")
                        
                        self.quotes.append(Quote(quote: quotOfTheDay, author: author, date: date, category: category))
                        
                    }
                    
                    //only main thread can write to screen
                    DispatchQueue.main.async {
                        self.quotes.forEach({ (quote) in
                            self.quote = quote.quote
                            self.author = quote.author
                        })
                    }

                }


                }.resume()

        }


    }
}

struct leaderboardEntry: Hashable{
    
    var displayName: String
    var score: String
    var rank: String
}

struct QuickWorkoutWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @State var showPopup: Bool = false
    @State var exerciseSelection = "Squats"
    @State var reps = ""
    @State var exercises: [String] = []
    @State var repsarray: [String] = []
    
    @State var editingExercise: Bool = false
    @State var editedExerciseIndex = 0
    
    @EnvironmentObject var appState: AppState
    
    @State var sets: String = "1"
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Text("Quick Workout")
                        .font(.custom("GothamMedium", size: 20))
                    
                    Button {
                        showPopup.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 75, height: 75)
                    }.padding(.leading, 25)
                    
                    
                }
                
                ForEach(exercises.indices, id: \.self) {i in
                    HStack {
                        Text(exercises[i])
                            .font(.custom("Gotham Regular", size: 25))
                        Spacer()
                            .frame(width: 100)
                        Text(repsarray[i])
                            .font(.custom("Gotham Regular", size: 25))
                    }
                    .frame(width: 350, height: 75)
                    .background(Color(.systemGray4))
                    .clipShape(Capsule())
                    .onLongPressGesture {
                        editedExerciseIndex = i
                        editingExercise = true
                    }
                }
                
                HStack {
                    Spacer()
                    Button {
                        let Workout = Workout()
                        Workout.Name = "Quick Workout"
                        for exercise in exercises {
                            Workout.Exercises.append(exercise)
                        }
                        for rep in repsarray {
                            Workout.reps.append(rep)
                        }
                        let email = Auth.auth().currentUser?.email ?? ""
                        let userdatafiles = userdata.realm.objects(User.self).where {
                            $0.email.starts(with: email)
                        }
                        if userdatafiles.count != 0 {
                            let userdatafile = userdatafiles.first!
                            Workout.Creator = userdatafile.Username
                        }
                        Workout.sets = Int(sets)!
                        try! userdata.realm.write {
                            userdatafiles.first!.Workouts.append(Workout)
                        }
                        PoseEstimator.shared.Exercises = exercises
                        PoseEstimator.shared.reps = repsarray
                        PoseEstimator.shared.isworkout = true
                        appState.target = .Workout
                        
                    } label: {
                        if !(exercises.count <= 0) {
                            Text("Start Workout")
                                .font(.custom("GothamMedium", size: 25))
                                .foregroundColor(.white)
                                .padding(15)
                                .background(.purple)
                        }
                        else {
                            Text("Start Workout")
                                .font(.custom("GothamMedium", size: 25))
                                .foregroundColor(Color(.systemGray))
                                .padding(15)
                                .background(Color(.systemGray5))
                        }
                    }.clipShape(Capsule())
                        .disabled(exercises.count <= 0)
                    Text("Sets:")
                    TextField("Sets", text: $sets)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                }
                

            }
        }
        .frame(maxWidth: 400, maxHeight: 200)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .frame(minHeight: 200)
                .foregroundColor(colorScheme == .dark ? Color(.systemGray5) : .white)
                .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
        }
        .PopUpNavigationViewController(HorizontalPadding: 40, show: $showPopup, exerciseList: $exercises, repslist: $repsarray, ColorScheme: colorScheme) {
            HStack {
                Spacer()
                Button {
                    showPopup.toggle()
                } label: {
                    Text("Cancel")
                }

            }
            HStack {
                Text("Exercise")
                    .font(.custom("GothamMedium", size: 20))
                Spacer()
                    .frame(width: 75)
                Text(exerciseSelection != "Break" ? "Reps" : "Time(mins)")
                    .font(.custom("GothamMedium", size: 20))
            }
            HStack {
                Picker(selection: $exerciseSelection, label: Text("Exercise")) {
                    ForEach(workoutexericselist, id: \.self) {exercise in
                        Text(exercise).tag(exercise)
                    }
                }
                .frame(width: 100)
                Spacer()
                    .frame(width: 70)
                TextField(exerciseSelection != "Break" ? "Reps" : "Time(mins)", text: $reps)
                    .keyboardType(.numberPad)
            }
            .padding(.leading, 40)
            
            Button {
                exercises.append(self.exerciseSelection)
                repsarray.append(self.reps)
                showPopup.toggle()
            } label: {
                Text("Done")
                    .font(.custom("GothamMedium", size: 25))
                    .frame(width: 100, height: 50)
                    .foregroundColor(.white)
                    .background(.purple)
                    .clipShape(Capsule())
            }

        }
        .EditExercisePopUp(EditingExercise: $editingExercise, index: editedExerciseIndex, ColorScheme: colorScheme) {
            
            HStack {
                Button {
                    editingExercise.toggle()
                } label: {
                    Text("Cancel")
                }
                
                Spacer()
                Button {
                    exercises.remove(at: editedExerciseIndex)
                    repsarray.remove(at: editedExerciseIndex)
                    editingExercise.toggle()
                } label: {
                    Text("Delete")
                }

            }
            HStack {
                Text("Exercise")
                    .font(.custom("GothamMedium", size: 20))
                Spacer()
                    .frame(width: 100)
                Text(exercises[editedExerciseIndex] != "Break" ? "Reps" : "Time(mins)")
                    .font(.custom("GothamMedium", size: 20))
            }
            HStack {
                Picker(selection: $exercises[editedExerciseIndex]) {
                    ForEach(workoutexericselist, id: \.self) {exercise in
                        Text(exercise).tag(exercise)
                    }
                } label: {
                    Text("Exercise")
                }
                
                Spacer()
                    .frame(width: 100)
                TextField(exercises[editedExerciseIndex] != "Break" ? "Reps" : "Time(mins)", text: $repsarray[editedExerciseIndex])
                    .keyboardType(.numberPad)

            }.padding(.leading, 40)
            Button {
                editingExercise.toggle()
            } label: {
                Text("Done")
                    .font(.custom("GothamMedium", size: 25))
                    .frame(width: 100, height: 50)
                    .foregroundColor(.white)
                    .background(.purple)
                    .clipShape(Capsule())
            }

        }
    }
    
}


struct LeaderboardWidget: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var LeaderboardEntries: [leaderboardEntry] = []
    @State var scrollViewDisabled = false
    @State var signedIn: Bool = false
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(.systemGray6))
            }
            if colorScheme == .light {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(.white)
                    .shadow(color: Color(.systemGray2    ), radius: 6, x: 0, y: 5)
            }
            
            ScrollView {
                VStack {
                    Text("Leaderboard")
                        .font(.custom("GothamMedium", size: 25))
                        .padding(.bottom, 15)
                    if !(self.LeaderboardEntries.count <= 0) && self.signedIn {
                        
                        HStack {
                            Text("Rank")
                                .padding(.leading, 15)
                            Spacer()
                            Text("Player")
                            Spacer()
                            Text("Calories Burnt")
                                .padding(.trailing, 15)
                        }
                        .frame(width: 350)
                        ForEach(LeaderboardEntries, id: \.self) { entry in
                            HStack {
                                Text(entry.rank)
                                    .padding(.leading, 15)
                                Spacer()
                                Text(entry.displayName)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(entry.score)
                                    .padding(.trailing, 15)
                            }
                            .frame(width: 340, height: 50)
                            .overlay {
                                Capsule()
                                    .stroke(.black, lineWidth: 1)
                            }
                            .padding(.vertical, 10)
                            
                            
                        }
                    }
                    else if self.LeaderboardEntries.count <= 0 {
                        Text("No Leaderboard entries Loaded yet")
                            .font(.custom("Gotham Regular", size: 20))
                            .padding(20)
                    }
                    
                    else if !self.signedIn {
                        Text("Click to Sign in to Game Centre")
                            .font(.custom("Gotham Regular", size: 25))
                            .onTapGesture {
                                authenticateLocalPlayer()
                            }
                    }
                }
            }
            .disabled(scrollViewDisabled)
            
        }
        .frame(width: 360, height: 250)
        .onAppear() {
            authenticateLocalPlayer()
            loadLeaderboardEntries()
            if self.LeaderboardEntries.count <= 0 || !self.signedIn {
                scrollViewDisabled = true
            }
        }
        
    }
    func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
        }
        self.signedIn = GKLocalPlayer.local.isAuthenticated
        print("GKLocalPlayer authentication: \(self.signedIn)")
    }
    
    func loadLeaderboardEntries() {
        GKLeaderboard.loadLeaderboards(IDs: ["WeeklyHighScore"]) {leaderboards, error in
            leaderboards?[0].loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 3)) { playerEntry, entries, size, error in
                if error != nil {
                    print("Error fetching leaderboard entries: \(error!.localizedDescription)")
                }
                
                if let entries = entries {
                    for entry in entries {
                        self.LeaderboardEntries.append(leaderboardEntry(displayName: entry.player.displayName, score: String(entry.score), rank: String(entry.rank)))
                        
                    }
                }
            }
        }
    }
}

//MARK: Widget Drawer Views

struct BlurView: UIViewRepresentable {
    var style : UIBlurEffect.Style
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct customCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct SheetDrawerContent: View {
    @State var allwidgets: [String] = ["recommendation","dailyquote", "leaderboard", "createexercise"] //add future widget types in here
    
    @Binding var widgets: [String]
    var body: some View {
        ScrollView {
            VStack {
                ForEach(allwidgets, id: \.self) {widgettype in
                    VStack(alignment: .leading) {
                        switch widgettype {
                        case "recommendation":
                            Text("Recommendations")
                                .padding(.bottom, 15)
                                .font(.custom("Gotham Medium", size: 20))
                            dropDownText(description: "Fitable Recommends you at least two exercises that best suits you")
                                .padding(.bottom, 23)
                        case "createexercise":
                            Text("Quick Workout")
                                .padding(.bottom, 15)
                                .font(.custom("Gotham Medium", size: 20))
                            dropDownText(description: "Quickly create a quick workout with exercises of your choosing, Fitable may assist you in choosing if you desire")
                                .padding(.bottom, 23)
                        case "leaderboard":
                            Text("Weekly Leaderboard")
                                .padding(.bottom, 15)
                                .font(.custom("Gotham Medium", size: 20))
                            dropDownText(description: "Shows the top 3 globally for the amount of calories burnt this week, needs you to be signed in to Game Centre")
                                .padding(.bottom, 23)
                        case "dailyquote":
                            Text("Daily Quote")
                                .padding(.bottom, 15)
                                .font(.custom("Gotham Medium", size: 20))
                            dropDownText(description: "A Daily quote of encouragement each day")
                                .padding(.bottom, 23)
                        default:
                            Text("unrecognised widget")
                            
                        }
                        Widget(widgetType: widgettype)
                            .padding(.bottom, 30)
                            .disabled(true)
                            .onDrag {
                                return NSItemProvider(contentsOf: URL(string: "\(widgettype)"))!
                            }
                            .onDrop(of: [.url], delegate: addWidgetDropDelegate(widgets: $widgets, widget: widgettype))
                            
                        
                        Divider()
                    }
                }
            }
        }
    }
}

struct addWidgetDropDelegate: DropDelegate {
    @Binding var widgets: [String]
    var widget: String
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        if !widgets.contains(widget) {
            widgets.append(widget)
            UserDefaults.standard.setValue(widgets, forKey: "HomeWidgets")
        }
    }
}

struct dropDownText: View {
    
    @State var expand = false
    @State var description: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Description")
                    .fontWeight(.regular)
                
                Image(systemName: expand ? "chevron.down" : "chevron.up")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .onTapGesture {
                
                self.expand.toggle()
            }
            
            if self.expand {
                Text(description)
                
            }
        }
        .padding(7)
        .animation(.spring(), value: self.expand)
    }
}
