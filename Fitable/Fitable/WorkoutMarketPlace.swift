//
//  Workouts.swift
//  Fitable
//
//  Created by Kiran Lim on 10/9/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import PhotosUI
import MobileCoreServices
import RealmSwift
import GoogleSignIn
import GoogleAPIClientForREST_Classroom


struct MarketPlace: View {
    
    @State var currenttab = "Exercises"
    @State var currentIndex = 0
    @EnvironmentObject var appState: AppState
    @State var TrendingWorkouts: [Workout] = []
    
    @State var searchText: String = ""
    var searchBarWorkouts: [Workout] {
        return searchText == "" ? allWorkouts : allWorkouts.filter {$0.Name.contains(searchText)}
    }
    @State var allWorkouts: [Workout] = []
    @State var username: String
    @Namespace var animation
    @Environment(\.colorScheme) var colorScheme
    @State var iscreatingWorkout = false
    
    @State var kdaThreshhold = 3
    @State var showDescription = false
    @State var showDescriptionWorkout: Workout?
    
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    @State var userdatafile: User = User(username: "", Email: "", Joindate: "", Userleague: .bronze)
    
    @State var showsheet: Bool = false
    @State var showhalfsheet: Bool = false
    @State var courses: [GTLRClassroom_Course] = []
    @State var user: GIDGoogleUser?
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 0){
                    Spacer()
                    ForEach(["Exercises", "MarketPlace"], id: \.self) {tab in
                        Button {
                            withAnimation {
                                currenttab = tab
                            }
                        }label: {
                            Text(tab)
                                .foregroundColor(currenttab == tab ? .white : colorScheme == .dark ? .white : .black)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 20)
                                .background{
                                    if currenttab == tab {
                                        RoundedRectangle(cornerRadius: 25)
                                            .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                                    }
                                }
                        }
                    }
                    
                        Button {
                            iscreatingWorkout.toggle()
                        }label: {
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                                .frame(width: 20, height: 20)
                                .padding(.leading, 20)
                                .padding(.trailing, 15)
                        }
                }
                .padding()
                
                if currenttab == "MarketPlace" {
                    Text("Suggested Routines").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                    
                    SnapCarousel(spacing: 20, trailingSpace: 110, index: $currentIndex, items: TrendingWorkouts) { post in
                        GeometryReader{proxy in
                            let size = proxy.size
                            
                            ZStack {
                                Image(uiImage: UIImage(data: post.image)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size.width, height: size.height)
                                    .cornerRadius(15)
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button {
                                            try! userdata.realm.write {
                                                if !userdatafile.Workouts.contains(post) {
                                                    userdatafile.Workouts.append(post)
                                                }
                                            }
                                        }label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 7)
                                                    .fill(Color(#colorLiteral(red: 0.3375000059604645, green: 0.3375000059604645, blue: 0.3375000059604645, alpha: 0.5299999713897705)))
                                                .frame(width: 59, height: 21)
                                                HStack {
                                                    Text("Save").font(.custom("Gotham-Bold", size: 11)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                                    Image(systemName: "bookmark")
                                                        .resizable()
                                                        .frame(width: 15, height: 15)
                                                        .foregroundColor(.white)
                                                }
                                                .padding()
                                            }
                                        }
                                        .padding([.trailing, .top], 5)
                                    }
                                    Spacer()
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 9)
                                            .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                        .frame(width: 162, height: 26)
                                        HStack {
                                            Text("\(post.Name)").font(.custom("Gotham-Bold", size: 12)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                            Image(systemName: "hand.thumbsup")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                            Text("\(post.likes.count)").font(.custom("Gotham-Bold", size: 12)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                            Image(systemName: "hand.thumbsdown")
                                                .resizable()
                                                .frame(width: 15, height: 15)
                                                .foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                            Text("\(post.dislikes.count)").font(.custom("Gotham-Bold", size: 12)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                        }
                                    }
                                    .padding(5)
                                }
                            }
                            .onTapGesture {
                                showDescriptionWorkout = post
                                showDescription = true
                            }
                        }
                    }
                    .padding(.top,70)
                    
                    HStack(spacing: 5) {
                        ForEach(TrendingWorkouts.indices, id: \.self){index in
                            Circle()
                                .fill(currentIndex == index ? .blue : .gray.opacity(0.55))
                                .frame(width: currentIndex == index ? 10 : 6, height: currentIndex == index ? 10 : 6)
                            
                        }
                    }
                    .animation(.easeInOut, value: currentIndex)
                    
                    HStack(spacing: 15){
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.gray)
                        TextField("Workout Name or tag", text: $searchText)
                            .autocorrectionDisabled(true)
                        
                        
                    }
                    .padding(5)
                    .overlay {
                        Capsule()
                            .stroke(LinearGradient(gradient: Gradient(colors: [Color(hex: "9090FF"), Color(hex: "90FFBC")]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                    }
                    .padding()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(searchBarWorkouts){workout in
                                Image(uiImage: UIImage(data: workout.image)!)
                                    .resizable()
                                    .frame(width: 100, height: 120)
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        showDescriptionWorkout = workout
                                        showDescription = true
                                    }

                            }
                        }
                        .padding()
                    }
                    
                }
                
                if currenttab == "Exercises" {
                    let columns = Array(repeating: GridItem(.flexible()), count: 2)
                    let exercises = ["Squats", "Push Ups","Jumping Jacks", "Burpees", "Single-Leg-Deadlifts"]
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(exercises, id: \.self) { exercise in
                            ZStack {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(LinearGradient(
                                            gradient: Gradient(stops: [
                                        .init(color: Color(#colorLiteral(red: 0.5686274766921997, green: 0.6549019813537598, blue: 0.9490196108818054, alpha: 1)), location: 0),
                                        .init(color: Color(#colorLiteral(red: 0.5686274766921997, green: 0.9019607901573181, blue: 0.800000011920929, alpha: 1)), location: 1)]),
                                            startPoint: UnitPoint(x: 0.4999999588148467, y: 3.225997780020862e-8),
                                            endPoint: UnitPoint(x: 0.8372092376405691, y: 1.3819444621693586)))
                                .frame(width: 161, height: 90)
                                .onTapGesture {
                                    PoseEstimator.shared.chosenExercise = exercise
                                    print(exercise)
                                    withAnimation {
                                        self.appState.target = .PoseEstimation
                                    }
                                }
                                .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:4)
                                Text(exercise).font(.custom("Gotham-Bold", size: 15)).foregroundColor(Color(#colorLiteral(red: 0.98, green: 0.99, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                                
                                
                            }
                        }
                        
                        
                    }
                    
                }
                
                Spacer()
                
                
            }
            if showDescription {
                GeometryReader{proxy -> AnyView in
                    let height = proxy.frame(in: .global).height
                    
                    
                    return AnyView (
                        ZStack {
                            BlurView(style: colorScheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
                                .clipShape(customCorner(corners: [.topLeft, .topRight], radius: 30))
                            
                            VStack {
                                Capsule()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 4)
                                    .padding(.top)
                                
                                HStack {
                                    Spacer()
                                    Text("\(showDescriptionWorkout!.Name)").font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                                        .padding(.top, 30)
                                    Label("Share", systemImage: "square.and.arrow.up")
                                        .contextMenu {
                                            Button {
                                                Task {
                                                    fetchclasses(Courses: $courses, showsheet: $showhalfsheet) { user, err in
                                                        self.user = user
                                                    }
                                                    print($courses)
                                                }
                                            } label: {
                                                Label("Share to Google Classroom", image: colorScheme == .dark ? "GoogleClassroom_Dark" : "GoogleClassroom_light")
                                            }
                                    
                                            Button {
                                                showsheet.toggle()
                                            } label: {
                                                Text("Share to other apps")
                                            }
                                        }
                                        .padding([.trailing, .top])
                                        .padding(.leading, 45)
                                        .sheet(isPresented: $showsheet) {
                                            ShareSheet(items: [URL(string: "https://www.google.com")!])
                                        }
                                        .halfSheet(showsheet: $showhalfsheet) {
                                            halfsheetView(courses: $courses, workout: showDescriptionWorkout!)
                                        }
                                }
                                
                                Image(uiImage: UIImage(data: showDescriptionWorkout!.image)!)
                                    .resizable()
                                    .frame(width: 190, height: 226)
                                    .cornerRadius(25)
                                    .padding(.top, 15)
                                
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Description:")
                                        .font(.custom("Gotham-Bold", size: 18))
                                        .foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                                        .padding(.top, 10)
                                    Text("\(showDescriptionWorkout!.Description)").font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                }
                                
                                if showDescriptionWorkout!.type == "Public" {
                                    let db = Firestore.firestore()
                                    let docref = db.collection("Workouts").document("\(showDescriptionWorkout!.Name)")
                                    HStack(spacing: 15) {
                                        Button {
                                            try! userdata.realm.write {
                                                showDescriptionWorkout?.likes.append(username)
                                                if showDescriptionWorkout!.dislikes.contains(username) {
                                                    if let index = showDescriptionWorkout!.dislikes.firstIndex(of: username) {
                                                        showDescriptionWorkout!.dislikes.remove(at: index)
                                                    }
                                                }
                                            }
                                            var likesarray: [String] = []
                                            for like in showDescriptionWorkout!.likes {
                                                likesarray.append(like)
                                            }
                                            var dislikesarray: [String] = []
                                            for dislike in showDescriptionWorkout!.dislikes {
                                                dislikesarray.append(dislike)
                                            }
                                            docref.updateData([
                                                "likes": likesarray,
                                                "dislikes": dislikesarray
                                            ]) {err in
                                                if let err = err {
                                                    print("Error updating document: \(err.localizedDescription)")
                                                }
                                                else {
                                                    
                                                    print("document updated successfully")
                                                }
                                            }
                                            
                                        }label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8.31)
                                                    .fill(Color(#colorLiteral(red: 0.3375000059604645, green: 0.3375000059604645, blue: 0.3375000059604645, alpha: 0.5299999713897705)))
                                                .frame(width: 75, height: 30)
                                                HStack {
                                                    Text("Like").font(.custom("Gotham-Bold", size: 13.1)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                                    Image(systemName: "hand.thumbsup")
                                                        .resizable()
                                                        .foregroundColor(Color(#colorLiteral(red: 0.8509804010391235, green: 0.8509804010391235, blue: 0.8509804010391235, alpha: 1)))
                                                    .frame(width: 19, height: 19)
                                                }
                                                
                                            }
                                        }
                                        
                                        Button {
                                            try! userdata.realm.write {
                                                showDescriptionWorkout?.dislikes.append(username)
                                                if showDescriptionWorkout!.likes.contains(username) {
                                                    if let index = showDescriptionWorkout!.likes.firstIndex(of: username) {
                                                        showDescriptionWorkout!.likes.remove(at: index)
                                                    }
                                                }
                                            }
                                            var likesarray: [String] = []
                                            for like in showDescriptionWorkout!.likes {
                                                likesarray.append(like)
                                            }
                                            var dislikesarray: [String] = []
                                            for dislike in showDescriptionWorkout!.dislikes {
                                                dislikesarray.append(dislike)
                                            }
                                            docref.updateData([
                                                "likes": likesarray,
                                                "dislikes": dislikesarray
                                            ]) {err in
                                                if let err = err {
                                                    print("Error updating document: \(err.localizedDescription)")
                                                }
                                                else {
                                                    
                                                    print("document updated successfully")
                                                }
                                            }
                                        }label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8.31)
                                                    .fill(Color(#colorLiteral(red: 0.3375000059604645, green: 0.3375000059604645, blue: 0.3375000059604645, alpha: 0.5299999713897705)))
                                                .frame(width: 75, height: 30)
                                                HStack {
                                                    Text("Dislike").font(.custom("Gotham-Bold", size: 13.1)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                                    Image(systemName: "hand.thumbsdown")
                                                        .resizable()
                                                        .foregroundColor(Color(#colorLiteral(red: 0.8509804010391235, green: 0.8509804010391235, blue: 0.8509804010391235, alpha: 1)))
                                                    .frame(width: 19, height: 19)
                                                }
                                                
                                            }
                                        }
                                        
                                        Button {
                                            try! userdata.realm.write {
                                                if !userdatafile.Workouts.contains(showDescriptionWorkout!) {
                                                    userdatafile.Workouts.append(showDescriptionWorkout!)
                                                }
                                            }
                                        }label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8.31)
                                                    .fill(Color(#colorLiteral(red: 0.3375000059604645, green: 0.3375000059604645, blue: 0.3375000059604645, alpha: 0.5299999713897705)))
                                                .frame(width: 75, height: 30)
                                                HStack {
                                                    Text("Save").font(.custom("Gotham-Bold", size: 13.1)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                                    Image(systemName: "bookmark")
                                                        .resizable()
                                                        .foregroundColor(Color(#colorLiteral(red: 0.8509804010391235, green: 0.8509804010391235, blue: 0.8509804010391235, alpha: 1)))
                                                    .frame(width: 19, height: 19)
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                
                                //Routine:
                                VStack(alignment: .leading) {
                                    Text("Routine:").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                    ScrollView {
                                        VStack {
                                            ForEach(Array(zip(showDescriptionWorkout!.Exercises.indices, showDescriptionWorkout!.Exercises)), id: \.0) {index, exercise in
                                                HStack(spacing: 10){
                                                    Image(exercise)
                                                        .resizable()
                                                        .frame(width: 69, height: 55)
                                                        .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15000000596046448)), radius:4, x:0, y:4)
                                                    
                                                    Text(" \(showDescriptionWorkout!.reps[index]) \(exercise)").font(.custom("Gotham-Bold", size: 18)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1)))
                                                }
                                            }
                                        }
                                    }
                                    
                                    
                                }
                                .padding(.top, 15)
                                
                                Button {
                                    for exercise in showDescriptionWorkout!.Exercises {
                                        PoseEstimator.shared.Exercises.append(exercise)
                                    }
                                    for rep in showDescriptionWorkout!.reps {
                                        PoseEstimator.shared.reps.append(rep)
                                    }
                                    PoseEstimator.shared.isworkout = true
                                    PoseEstimator.shared.currentReps = Int(showDescriptionWorkout!.reps[0])!
                                    PoseEstimator.shared.chosenExercise = showDescriptionWorkout!.Exercises[0]
                                    PoseEstimator.shared.isbreak = false
                                    PoseEstimator.shared.pause = false
                                    appState.target = .Workout
                                }label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5.45)
                                            .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                                        .frame(width: 280, height: 42)
                                        Text("Start").font(.custom("Gotham-Bold", size: 20)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                                    }
                                }
                                
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                            .offset(y: height - 100)
                            .offset(y: offset)
                            .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                                
                                out = value.translation.height
                                if out > 28 {
                                    DispatchQueue.main.async {
                                        showDescription.toggle()
                                    }
                                }
                                onChange()
                            }).onEnded({ value in
                                let maxHeight = height - 100
                                withAnimation {
                                    
                                    if -offset > maxHeight {
                                        offset = -maxHeight
                                    }
                                    
                                }
                                
                                lastOffset = offset
                            }))
                            
                    )
                }
                .transition(.move(edge: .bottom))
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            let db = Firestore.firestore()
            let storage = Storage.storage()
            let StorageRef = storage.reference()
            db.collection("Workouts").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {

                    for document in querySnapshot!.documents {
                        let workout = Workout()

                        workout.Name = document.get("Name") as! String
                            workout.Description = document.get("Description") as! String
                        for exercise in document.get("Exercises") as! [String] {
                            workout.Exercises.append(exercise)
                        }
                        for rep in document.get("reps") as! [String]{
                            workout.reps.append(rep)
                        }


                        workout.Creator = document.get("Creator") as! String
                        workout.Time = document.get("Time") as! Int
                        workout.sets = document.get("Sets") as! Int
                        let likes = document.get("likes") as! [String]
                        workout.type = document.get("type") as! String
                        for like in likes {
                            workout.likes.append(like)
                        }
                        let dislikes = document.get("dislikes") as! [String]
                        for dislike in dislikes {
                            workout.dislikes.append(dislike)
                        }
                        let ref = StorageRef.child("Workouts/\(workout.Name)")
                        ref.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("Error getting image data: \(error.localizedDescription)")
                            }
                            else {
                                print("Image Data: \(data!)")
                                workout.image = data!
                                DispatchQueue.main.async {
                                    if workout.likes.count != 0 || workout.dislikes.count != 0 {
                                        if workout.likes.count / workout.dislikes.count >= kdaThreshhold {
                                            TrendingWorkouts.append(workout)
                                        }
                                        allWorkouts.append(workout)
                                    }
                                    else {
                                        allWorkouts.append(workout)
                                    }
                                }
                            }
                        }

                    }
                }
            }
            
            let email = Auth.auth().currentUser?.email ?? ""
            let userdatafiles = userdata.realm.objects(User.self).where {
                $0.email.starts(with: email)
            }
            if userdatafiles.count != 0 {
                userdatafile = userdatafiles.first!
            }
        }
        .sheet(isPresented: $iscreatingWorkout) {
            CreateWorkoutPage(iscreatingWorkout: $iscreatingWorkout)
        }
        
        
    }
    func onChange() {
        DispatchQueue.main.async {
            
            self.offset = gestureOffset + lastOffset
        }
    }
    
}




struct SnapCarousel<Content: View,T: Identifiable>: View{
    var content: (T) -> Content
    var list: [T]
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    init(spacing: CGFloat = 15, trailingSpace: CGFloat = 100, index: Binding<Int>, items: [T], @ViewBuilder content: @escaping (T) -> Content) {
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    var body: some View {
        GeometryReader{proxy in
            
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustMentWidth = (trailingSpace / 2) - spacing
            HStack(spacing: spacing) {
                ForEach(list){item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace)
                        .offset(y: gotoffset(item: item, width: width))
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustMentWidth : 0) + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = (value.translation.width / 1.5)
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        
                        let progress = -offsetX / width
                        
                        let roundIndex =  progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        
                        currentIndex = index
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        
                        let progress = -offsetX / width
                        
                        let roundIndex =  progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        
                    })
            )
        }
        .animation(.easeInOut, value: offset == 0)
    }
    
    func gotoffset(item: T,width: CGFloat) -> CGFloat {
        
        let progress = ((offset < 0 ? offset : -offset) / width) * 60
        let topOffset = -progress < 60 ? progress : -(progress + 120)
        let previous = getIndex(item: item) - 1 == currentIndex ? (offset < 0 ? topOffset : -topOffset) : 0
        let next = getIndex(item: item) + 1 == currentIndex ? (offset < 0 ? -topOffset : topOffset) : 0
        
        let checkBetween = currentIndex >= 0  && currentIndex < list.count ? (getIndex(item: item) - 1 == currentIndex ? previous : next) : 0
        
        
        return getIndex(item: item) == currentIndex ? -60 - topOffset : checkBetween
    }
    
    func getIndex(item: T)-> Int{
        let index = list.firstIndex { currentItem in
            return currentItem.id == item.id
        } ?? 0
        return index
    }
}

struct CreateWorkoutPage: View {
    @State var username: String = ""
    @Binding var iscreatingWorkout: Bool
    @State var selectedPhoto: PhotosPickerItem?
    @State var selectedPhotoData: Data?
    @State var workout: Workout = Workout(name: "", creator: "", time: 30, description: "", Sets: 1, difficulty: .Intermediate)
    @State var Title: String = ""
    @State var Description: String  = ""
    @State var Exercises: [String] = []
    @State var reps: [String] = []
    @State var columns = Array(repeating: GridItem(.flexible(), spacing: 70), count: 3)
    
    @State var exerciseSelection: String = ""
    @State var repsadded: String = ""
    @State var isaddingexercises = false
    
    @State var iseditingExercise = false
    @State var editedExerciseIndex = 0
    @State var Time = "Time Taken(minutes)"
    @State var sets = "# of Sets"
    @State var showpopup = false
    @Environment(\.colorScheme) var colorScheme
    
    @State var userdatafile: User = User(username: "", Email: "", Joindate: "", Userleague: .bronze )
    var body: some View {
        
        VStack {
            Text("Create a New Routine").font(.custom("Gotham-Bold", size:20)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                .padding(.top, 10)
            HStack {
                
                ZStack {
                    if let selectedPhotoData, let image = UIImage(data: workout.image) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 150, height: 177)
                    }
                    else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 9.69)
                                .fill(Color(#colorLiteral(red: 0.8509804010391235, green: 0.8509804010391235, blue: 0.8509804010391235, alpha: 1)))
                            .frame(width: 150, height: 177)
                            Image("add photo")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    PhotosPicker(selection: $selectedPhoto, matching: .any(of: [.images]), photoLibrary: .shared()) {
                        RoundedRectangle(cornerRadius: 9.69)
                            .fill(Color(#colorLiteral(red: 0.8509804010391235, green: 0.8509804010391235, blue: 0.8509804010391235, alpha: 0)))
                        .frame(width: 150, height: 177)
                        .onChange(of: selectedPhoto) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedPhotoData = data
                                    workout.image = data
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                }
                
                VStack {
                    TextField("Title...", text: $Title)
                        .font(.custom("Gotham-Bold", size: 15)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                        .lineLimit(2)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                .fill(Color(#colorLiteral(red: 0.9583333134651184, green: 0.9583333134651184, blue: 0.9583333134651184, alpha: 1)))

                                RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(Color(#colorLiteral(red: 0.8833333253860474, green: 0.8833333253860474, blue: 0.8833333253860474, alpha: 1)), lineWidth: 1)
                            }
                            .frame(width: 167, height: 68)
                        }
                        .frame(width: 167, height: 68)
                    
                    TextField("Time Taken(minutes)", text: $Time)
                        .font(.custom("Gotham-Bold", size: 15)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                        .lineLimit(2)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                .fill(Color(#colorLiteral(red: 0.9583333134651184, green: 0.9583333134651184, blue: 0.9583333134651184, alpha: 1)))

                                RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(Color(#colorLiteral(red: 0.8833333253860474, green: 0.8833333253860474, blue: 0.8833333253860474, alpha: 1)), lineWidth: 1)
                            }
                            .frame(width: 167, height: 30)
                        }
                        .frame(width: 167, height: 30)
                    
                    TextField("# of Sets:", text: $sets)
                        .font(.custom("Gotham-Bold", size: 15)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                        .lineLimit(2)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                .fill(Color(#colorLiteral(red: 0.9583333134651184, green: 0.9583333134651184, blue: 0.9583333134651184, alpha: 1)))

                                RoundedRectangle(cornerRadius: 5)
                                .strokeBorder(Color(#colorLiteral(red: 0.8833333253860474, green: 0.8833333253860474, blue: 0.8833333253860474, alpha: 1)), lineWidth: 1)
                            }
                            .frame(width: 167, height: 30)
                        }
                        .frame(width: 167, height: 30)
                    
                }
                
                
                
            }
            TextField("Description...", text: $Description)
                .font(.custom("Gotham-Bold", size: 15)).foregroundColor(Color(#colorLiteral(red: 0.52, green: 0.52, blue: 0.63, alpha: 1)))
                .lineLimit(4)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                        .fill(Color(#colorLiteral(red: 0.9583333134651184, green: 0.9583333134651184, blue: 0.9583333134651184, alpha: 1)))

                        RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(Color(#colorLiteral(red: 0.8833333253860474, green: 0.8833333253860474, blue: 0.8833333253860474, alpha: 1)), lineWidth: 1)
                    }
                    .frame(width: 315, height: 68)
                }
                .frame(width: 315, height: 68)
                .padding(.top, 5)
            HStack {
                Spacer()
                Button {
                    isaddingexercises.toggle()
                }label: {
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                        .frame(width: 20, height: 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 15)
                }
                .padding(.trailing, 15)
            }
            .padding(.top, 10)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 45) {
                    ForEach(Exercises.indices, id: \.self) {index in
                        ZStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5.45)
                                .fill(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))

                                RoundedRectangle(cornerRadius: 5.45)
                                .strokeBorder(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), lineWidth: 1)
                            }
                            .compositingGroup()
                            .frame(width: 118, height: 70)
                            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)), radius:4, x:0, y:4)
                            VStack {
                                Text(Exercises[index] != "Break" ? "x\(reps[index])" : "\(reps[index])m").font(.custom("Gotham-Bold", size: 25)).multilineTextAlignment(.center)
                                    .foregroundStyle(.linearGradient(Gradient(colors: [Color(hex: "92E6CD"), Color(hex: "9195FD")]), startPoint: .leading, endPoint: .trailing))
                                Text(Exercises[index]).font(.custom("Gotham-Bold", size: 25)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                            }
                            .frame(width: 118, height: 70)
                            .onLongPressGesture {
                                iseditingExercise.toggle()
                                editedExerciseIndex = index
                                
                            }
                        }
                        
                    }
                    .frame(maxWidth: 365)
                    
                }
                .padding(.horizontal, 40)
            }
            .padding(.top, 10)
            
            Button {
                
                showpopup.toggle()
            }label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5.45)
                        .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                    .frame(width: 297, height: 39)
                    
                    
                    Text("Finish").font(.custom("Gotham Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                }
            }
            .disabled(Title == "" || Description  == "" || Exercises == [] || reps == [] || Time == "" || sets == "")
            
            Spacer()
            
            
        }
        .popover(isPresented: $isaddingexercises) {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isaddingexercises.toggle()
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
                    TextField(exerciseSelection != "Break" ? "Reps" : "Time(mins)", text: $repsadded)
                        .keyboardType(.numberPad)
                }
                .padding(.leading, 40)
                
                Button {
                    Exercises.append(self.exerciseSelection)
                    reps.append(self.repsadded)
                    isaddingexercises.toggle()
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
        .popover(isPresented: $iseditingExercise) {
            VStack {
                HStack {
                    Button {
                        iseditingExercise.toggle()
                    } label: {
                        Text("Cancel")
                    }
                    
                    Spacer()
                    Button {
                        Exercises.remove(at: editedExerciseIndex)
                        reps.remove(at: editedExerciseIndex)
                        iseditingExercise.toggle()
                    } label: {
                        Text("Delete")
                    }

                }
                HStack {
                    Text("Exercise")
                        .font(.custom("GothamMedium", size: 20))
                    Spacer()
                        .frame(width: 100)
                    Text(Exercises[editedExerciseIndex] != "Break" ? "Reps" : "Time(mins)")
                        .font(.custom("GothamMedium", size: 20))
                }
                HStack {
                    Picker(selection: $Exercises[editedExerciseIndex]) {
                        ForEach(workoutexericselist, id: \.self) {exercise in
                            Text(exercise).tag(exercise)
                        }
                    } label: {
                        Text("Exercise")
                    }
                    
                    Spacer()
                        .frame(width: 100)
                    TextField(Exercises[editedExerciseIndex] != "Break" ? "Reps" : "Time(mins)", text: $reps[editedExerciseIndex])
                        .keyboardType(.numberPad)

                }.padding(.leading, 40)
                Button {
                    iseditingExercise.toggle()
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
        .onAppear() {
            let email = Auth.auth().currentUser?.email ?? ""
            let userdatafiles = userdata.realm.objects(User.self).where {
                $0.email.starts(with: email)
            }
            if userdatafiles.count != 0 {
                userdatafile = userdatafiles.first!
            }
            username = userdatafile.Username
        }
        .PopUp(show: $showpopup, ColorScheme: colorScheme) {
            ZStack {
                customBlurView(effect: colorScheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
                    .frame(width: 270, height: 151)
                    .cornerRadius(15)
                
                VStack {
                    Text("Make routine public? Other users will be able\nuse, like and dislike your\nroutine.").font(.custom("Gotham-Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 0.24, green: 0.25, blue: 0.42, alpha: 1))).multilineTextAlignment(.center)
                    
                    HStack(spacing: 10) {
                        Button {
                            
                            
                            self.iscreatingWorkout.toggle()
                            showpopup.toggle()
                            try! userdata.realm.write {
                                workout.Name = Title
                                workout.Description = Description
                                workout.sets = Int(sets)!
                                workout.Time = Int(Time)!
                                workout.Creator = username
                                for exercise in Exercises {
                                    workout.Exercises.append(exercise)
                                }
                                for rep in reps {
                                    workout.reps.append(rep)
                                }
                                workout.type = "Public"
                                userdatafile.Workouts.append(workout)
                            }
                            
                            let db = Firestore.firestore()
                            db.collection("Workouts").document("\(Title)").setData([
                                "Creator": username,
                                "Description": Description,
                                "Exercises": Exercises,
                                "Name": Title,
                                "Sets": Int(sets)!,
                                "reps": reps,
                                "Time": Int(Time)!,
                                "likes": [],
                                "dislikes": [],
                                "type": workout.type
                            ]) {err in
                                if let err = err {
                                    print("Error setting document: \(err.localizedDescription)")
                                }
                                else {
                                    print("Document successfully written")
                                }
                            }
                            
                            let storage = Storage.storage()
                            let storageref = storage.reference()
                            let workoutref = storageref.child("Workouts/\(Title)")
                            
                            let uploadTask = workoutref.putData(workout.image, metadata: nil) {(metadata, error) in
                                if error != nil {
                                    print("error uploading image: \(error?.localizedDescription)")
                                }
                            }
                            
                        }label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5.45)
                                    .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                                .frame(width: 110, height: 32)
                                Text("Yes").font(.custom("Gotham Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: 110, height: 32)
                        
                        Button {
                            self.iscreatingWorkout.toggle()
                            showpopup.toggle()
                            try! userdata.realm.write {
                                workout.Name = Title
                                workout.Description = Description
                                workout.sets = Int(sets)!
                                workout.Time = Int(Time)!
                                workout.Creator = username
                                for exercise in Exercises {
                                    workout.Exercises.append(exercise)
                                }
                                for rep in reps {
                                    workout.reps.append(rep)
                                }
                                workout.type = "Private"
                                userdatafile.Workouts.append(workout)
                            }
                        }label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5.45)
                                    .fill(Color(#colorLiteral(red: 0.24313725531101227, green: 0.24705882370471954, blue: 0.4156862795352936, alpha: 1)))
                                .frame(width: 110, height: 32)
                                
                                Text("No").font(.custom("Gotham Bold", size: 16)).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))).multilineTextAlignment(.center)
                            }
                            
                        }
                        .frame(width: 110, height: 32)
                    }
                    .padding(.top, 15)
                }
            }
            .frame(width: 270, height: 151)
            
        }
    }
    
}



struct marketplacepreview: PreviewProvider{
    static var previews: some View {
        MarketPlace(username: "TYPHOON345")
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE(3rd Generation)")
    }
}
