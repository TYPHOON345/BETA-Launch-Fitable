//
//  HomeView.swift
//  Fitable
//
//  Created by Kiran Lim on 30/7/22.
//

import SwiftUI
import Charts
import Firebase
import FirebaseAuth
import MobileCoreServices
import GoogleAPIClientForREST_Classroom
import GoogleSignIn
import Network

//case recommendation
//case leaderboard
//case createexercise
//case dailyquote

struct DropViewDelegate: DropDelegate {
    var widget: String
    @Binding var widgets: [String]
    @Binding var currentwidget: String
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        let fromIndex = widgets.firstIndex { (widget) -> Bool in
            return widget == currentwidget
        } ?? 0
        
        let toIndex = widgets.firstIndex { (widget) -> Bool in
            return widget == self.widget
        } ?? 0
        
        if fromIndex != toIndex{
            withAnimation(.default) {
                let fromWidget = widgets[fromIndex]
                widgets[fromIndex] = widgets[toIndex]
                widgets[toIndex] = fromWidget
                UserDefaults.standard.setValue(widgets, forKey: "HomeWidgets")
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
struct HomeView: View {
    
    @State var userdatafile: User = User(username: "", Email: "", Joindate: "", Userleague: .bronze)
    @State var currentTab: String = "Week"
    
    @State var selected = 0
    @EnvironmentObject var appState: AppState
    @State var notconnected = false
    
    let columns = [GridItem(.flexible(), spacing: 45)]
    @State var currentWidget: String = "leaderboard"
    @State var Widgets: [String] = []
    @State var showViews: [Bool] = Array(repeating: false, count: 10)
    @State var showViewIndex: Int = 0
    
    @State var presentSubmissionDetails: Bool = false
    @State var presentWorkoutView: Bool = false
    @State var studentworkoutresults: WorkoutResults = WorkoutResults(overallAccuracy: 0, Exercises: [], ExerciseAccuracy: [], comments: [])
    @State var studentName = ""
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    @State var isediting = false
    
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            switch self.selected {
            case 0:
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack {
                        VStack {
                            Ellipse()
                              .fill(LinearGradient(gradient: Gradient(stops: [.init(color: Color(hex: "9090FF"), location: 0.00), .init(color: Color(hex: "90FFBC"), location: 1.00)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                              .frame(width: 867, height: 405)
                              .position(x: 160, y: 0)
                            Spacer()
                        }
                        .background {
                            Color(hex: "F5F5F5")
                        }
                        
                        VStack {
                            
                            VStack(alignment: .leading){
                                Text("Hello \(userdatafile.Username)")
                                    .font(.custom("Gotham-Bold", size: 20))
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                Spacer()
                                    .frame(height: 30)
                                Text("Your Activity")
                                    .font(.custom("Gotham Regular", size: 20))
                                    .foregroundColor(.white)
                                Activitywidget(userdatafile: userdatafile)
                                    .frame(width: 350, height: 200)
                            }
                            .padding(.bottom, 40)

                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 50 ) {
                                ForEach(self.Widgets, id: \.self) {widget in
                                    ZStack {
                                        Widget(widgetType: widget)
                                            .onDrag {
                                                currentWidget = widget
                                                return NSItemProvider(contentsOf: URL(string: "\(widget)")!)!
                                            }
                                            .onDrop(of: [.url], delegate: DropViewDelegate(widget: widget, widgets: $Widgets, currentwidget: $currentWidget))
                                            .environmentObject(appState)
                                        if isediting {
                                            Image(systemName: "x.circle.fill")
                                                .frame(width: 60, height: 60)
                                                .position(x: 15, y: 15)
                                                .transition(.scale)
                                                .onTapGesture {
                                                    withAnimation {
                                                        self.Widgets.removeAll(where: {$0 == widget})
                                                        UserDefaults.standard.setValue(Widgets, forKey: "HomeWidgets")
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            
                            
                        }
                        .onLongPressGesture {
                            isediting.toggle()
                        }

                        
                        
                    }
                    
                    .frame(width: 375, height: 1300)
                        
                    
                }.ignoresSafeArea(.all)
            case 1:
                GeometryReader {_ in
                    Analyticsview()
                }
            case 2:
                GeometryReader {_ in
                    MarketPlace(username: appState.username)
                }
            case 3:
                GeometryReader {_ in
                    ProfileView(userdatafile: userdatafile)
                }
            default:
                GeometryReader {_ in
                    Text("default view")
                }
            }
            
            
            FloatingTabBar(selected: self.$selected)
            
            if isediting {
                GeometryReader{proxy -> AnyView in
                    let height = proxy.frame(in: .global).height
                    
                    return AnyView (
                        ZStack {
                            BlurView(style: colorScheme == .dark ? .systemThinMaterialDark : .systemThinMaterialLight)
                                .clipShape(customCorner(corners: [.topLeft, .topRight], radius: 30))
                            
                            VStack {
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 4)
                                    .padding(.top)
                                
                                Text("Add Widgets")
                                    .font(.custom("GothamMedium", size: 25))
                                    .padding(15)
                                SheetDrawerContent(widgets: $Widgets)
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                            .offset(y: height - 100)
                            .offset(y: offset)
                            .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                                
                                out = value.translation.height
                                onChange()
                            }).onEnded({ value in
                                let maxHeight = height - 100
                                withAnimation {
                                    
                                    if -offset > maxHeight / 1.5{
                                        offset = -maxHeight / 1.5
                                    }
                                }
                                
                                lastOffset = offset
                            }))
                            
                    )
                }
                .transition(.move(edge: .bottom))
            }
        }
        .fullScreenCover(isPresented: $presentSubmissionDetails, content: {
            StudentSubmissionResultsview(studentName: studentName, workoutResults: $studentworkoutresults)
        })
        .sheet(isPresented: $notconnected, content: {
            AlertView(isshown:  $notconnected, Title: "", Message: "", type: .networknotification)
        })
        
        
            .onAppear {
                let monitor = NWPathMonitor()
                monitor.pathUpdateHandler = {path in
                    if path.status == .satisfied {
                        notconnected = false
                    }
                    else {
                        notconnected = true
                    }
                }
                
                let networkqueue = DispatchQueue(label: "Network Monitor")
                monitor.start(queue: networkqueue)
                
                
                let email = Auth.auth().currentUser?.email ?? ""
                let userdatafiles = userdata.realm.objects(User.self).where {
                    $0.email.starts(with: email)
                }
                if userdatafiles.count != 0 {
                    userdatafile = userdatafiles.first!
                }
                Widgets = UserDefaults.standard.array(forKey: "HomeWidgets") as? [String] ?? []
                
                try! userdata.realm.write {
                    if userdatafile.ExerciseData.count == 0 {
                        userdatafile.currentDay = Days(Day: Date.now.formatted(.dateTime.weekday()), Date: Date.now)
                        userdatafile.ExerciseData.append(userdatafile.currentDay!)
                        print("ExerciseData: \(userdatafile.ExerciseData)")
                    }
                    
                    let diff = Calendar.current.dateComponents([.day], from: userdatafile.currentDay!.date, to: Date.now)
                    print("Day difference: \(diff.day!)")
                    let currenthour = Date.now.formatted(.dateTime.hour())
                    if userdatafile.currentDay?.calorieshour.last?.hour != currenthour {
                        userdatafile.currentDay?.calorieshour.append(Hour(Hour: currenthour))
                    }
                    print("current hour: \(currenthour)")
                    if diff.day! > 0 || Date.now.formatted(.dateTime.day()) != userdatafile.currentDay?.date.formatted(.dateTime.day()){
                        if userdatafile.ExerciseData.count >= userdatafile.ExerciseDataMax {
                            userdatafile.ExerciseData.remove(at: 0)
                        }
                        
                        userdatafile.currentDay = Days(Day: Date.now.formatted(.dateTime.weekday(.wide)), Date: Date.now)
                        userdatafile.ExerciseData.append(userdatafile.currentDay!)
                    }
                }
            }
            .onOpenURL { url in
                print("incoming url is \(url)")
                let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
                    guard error == nil else {
                        print("Found An Error: \(error?.localizedDescription)")
                        return
                    }
                    
                    if let dynamiclink = dynamiclink {
                        self.handleIncomingDynamicLink(dynamiclink)
                    }
                }
            }
        
    }
    func handleIncomingDynamicLink(_ DynamicLink: DynamicLink) {
        guard let url = DynamicLink.url else {
            print("That's weird, my dynamic link has no url")
            return
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let components = components {
            if let queryItems = components.queryItems {
                if queryItems.last?.value == "Assignment" {
                    let courseID = components.queryItems![3].value!
                    print("CourseID: \(courseID)")
                    isStudent(courseID: courseID) { isstudent, error in
                        guard error == nil else {
                            print("Error with validation of student: \(error?.localizedDescription)")
                            return
                        }
                        
                        if let isstudent = isstudent {
                            if isstudent {
                                let workout = Workout()
                                for queryItem in queryItems {
                                    switch queryItem.name {
                                    case "workoutID":
                                        workout.Name = queryItem.value!
                                    case "time":
                                        workout.Time = Int(queryItem.value!)!
                                    case "sets":
                                        workout.sets = Int(queryItem.value!)!
                                    case "Exercise":
                                        workout.Exercises.append(queryItem.value!)
                                    case "Rep":
                                        workout.reps.append(queryItem.value!)
                                    default:
                                        print("Unrecognised queryitemname: \(queryItem.name)")
                                    }
                                }
                                print("workout formed: \(workout)")
                                presentWorkoutView = true
                            }
                        }
                    }
                }
                if queryItems.last?.value == "Submission" {
                    let courseID = components.queryItems![3].value!
                    GIDSignIn.sharedInstance.restorePreviousSignIn(){user, error in
                        user?.authentication.do {authentication, error in
                            let service = GTLRClassroomService()
                            service.authorizer = authentication?.fetcherAuthorizer()
                            isTeacher(courseID: courseID) { isteacher, error in
                                guard isteacher != nil else {
                                    print("isteacher is nil")
                                    return
                                }
                                guard error == nil else {
                                    print("Error found when fetching teachers: \(error!.localizedDescription)")
                                    return
                                }
                                if let isteacher = isteacher {
                                    if isteacher{
                                        for queryItem in queryItems {
                                            switch queryItem.name {
                                            case "Name":
                                                studentName = queryItem.value!
                                            case "OverallAccuracy":
                                                studentworkoutresults.overallAccuracy = Int(queryItem.value!)!
                                            case "Exercise":
                                                studentworkoutresults.Exercises.append(queryItem.value!)
                                            case "Accuracy":
                                                studentworkoutresults.ExerciseAccuracy.append(Int(queryItem.value!)!)
                                            case "Comment":
                                                studentworkoutresults.comments.append(queryItem.value!)
                                            
                                            default:
                                                print("Unrecognised queryitem: \(queryItem.name)")
                                            }
                                        }
                                        presentSubmissionDetails = true
                                    }
                                }
                                
                                
                            }
                        }
                    }
                }
            }
        }
    }
     
    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
}





struct FloatingTabBar: View {
    
    @Binding var selected: Int
    @State var expand = false
    var body: some View{
        HStack {
            Spacer(minLength: 0)
            HStack {
                if !self.expand {
                    Button {
                        self.expand.toggle()
                    } label: {
                        Image(systemName: "arrow.left").foregroundColor(.black)
                            .padding()
                    }

                }
                else {
                    Button {
                        self.selected = 0
                    } label: {
                        Image(systemName: "homekit")
                            .foregroundColor(.black)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 15)
                    Button {
                        self.selected = 1
                    } label: {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.black)
                            .padding(.horizontal)
                    }
                    Spacer(minLength: 15)
                    Button {
                        self.selected = 2
                    } label: {
                        Image("dumbell")
                            .resizable()
                            .frame(width: 25, height: 19)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 15)
                    
                    Button {
                        self.selected = 3
                    } label: {
                        Image(systemName: "person")
                            .foregroundColor(.black)
                            .padding(.horizontal)
                    }
                }


            }.padding(.vertical, self.expand ? 20 : 8)
                .padding(.horizontal, self.expand ? 35 : 8)
            .background(Color.white)
            .clipShape(Capsule())
            .padding(22)
            .onTapGesture {
                self.expand.toggle()
            }
            .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6), value: self.expand)
        }
    }
}



extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
