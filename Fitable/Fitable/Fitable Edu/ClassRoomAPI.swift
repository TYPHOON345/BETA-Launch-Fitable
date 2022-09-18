//
//  ClassRoomAPI.swift
//  Fitable
//
//  Created by Kiran Lim on 1/9/22.
//

import Foundation
import GoogleSignIn
import SwiftUI
import GoogleAPIClientForREST_Classroom

import FirebaseDynamicLinks

//
//@State var workoutselected: Workout = Workout(name: "", creator: "", time: 30, description: "", Sets: 2, difficulty: .Intermediate)
//@State var showsheet: Bool = false
//@State var showhalfsheet: Bool = false
//@State var courses: [GTLRClassroom_Course] = []
//@State var user: GIDGoogleUser?

//MARK: Share Button
//Label("Share", systemImage: "square.and.arrow.up")
//    .contextMenu {
//        Button {
//            Task {
//                fetchclasses(Courses: $courses, showsheet: $showhalfsheet) { user, err in
//                    self.user = user
//                }
//                print($courses)
//            }
//        } label: {
//            Label("Share to Google Classroom", image: colorScheme == .dark ? "GoogleClassroom_Dark" : "GoogleClassroom_light")
//        }
//
//        Button {
//            showsheet.toggle()
//        } label: {
//            Text("Share to other apps")
//        }
//    }
//    .sheet(isPresented: $showsheet) {
//        ShareSheet(items: [URL(string: "https://www.google.com")!])
//    }
//    .halfSheet(showsheet: $showhalfsheet) {
//        halfsheetView(courses: $courses, workout: workoutselected)
//    }


func isTeacher(courseID: String , completionHandler: @escaping (Bool?, Error?) -> Void){

    GIDSignIn.sharedInstance.restorePreviousSignIn {user, error in
        user?.authentication.do {authentication, error in
            guard let authentication = authentication else {return}
            let service = GTLRClassroomService()
            service.authorizer = authentication.fetcherAuthorizer()
            let query = GTLRClassroomQuery_CoursesTeachersList.query(withCourseId: courseID)
            service.executeQuery(query) {ticket, filelist, error in
                if error != nil {
                    print("Error fetching teachers, \(error?.localizedDescription)")
                    completionHandler(nil, error)
                }
                if let teacherlist = filelist as? GTLRClassroom_ListTeachersResponse {
                    print("teacherlist: \(teacherlist)")
                    
                    completionHandler(teacherlist.teachers?.contains(where: {$0.userId == user?.userID!}), nil)
                }
                
                
            }
            
        }
    }
}

func isStudent(courseID: String,completionHandler: @escaping (Bool?, Error?)-> Void) {
    GIDSignIn.sharedInstance.restorePreviousSignIn {user, error in
        if user == nil || error != nil {
            let config = GIDConfiguration(clientID: "342162894109-jf2fc1h8l2oe75vj05qn11mipcrhj56h.apps.googleusercontent.com")
            
            GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController(), hint: "", additionalScopes: ["https://www.googleapis.com/auth/classroom.coursework.students", "https://www.googleapis.com/auth/classroom.courses","https://www.googleapis.com/auth/classroom.rosters", "https://www.googleapis.com/auth/classroom.coursework.me"]) {user, error in
                guard error == nil else {
                    completionHandler(nil, error)
                    print("Sign in failed with error: \(error?.localizedDescription)")
                    return
                }
                guard let user = user else {
                    return
                }
                user.authentication.do {authentication, error in
                    guard error == nil else {
                        print("error with refreshing completion handler: \(error?.localizedDescription)")
                        completionHandler(nil, error)
                        return}
                    
                    guard let authentication = authentication else {return}
                    
                    let service = GTLRClassroomService()
                    service.authorizer = authentication.fetcherAuthorizer()
                    let query = GTLRClassroomQuery_CoursesStudentsList.query(withCourseId: courseID)
                    service.executeQuery(query){ticket, filelist, error in
                        if error != nil {
                            
                            completionHandler(nil, error)
                            print("error fetching students: \(error?.localizedDescription)")
                        }
                        
                        if let studentlist = filelist as? GTLRClassroom_ListStudentsResponse {
                            print("studentlist: \(studentlist)")
                            completionHandler(studentlist.students?.contains(where: {$0.userId == user.userID!}), nil)
                        }
                    }
                    
                    
                }
                
            }
        }
        else {
            let grantedScopes = user?.grantedScopes
            if grantedScopes == nil || !grantedScopes!.contains("https://www.googleapis.com/auth/classroom.coursework.students") || !grantedScopes!.contains("https://www.googleapis.com/auth/classroom.courses"){
                //requesting additional scopes to create coursework
                let additionalScopes = ["https://www.googleapis.com/auth/classroom.coursework.students", "https://www.googleapis.com/auth/classroom.courses"]
                GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: getRootViewController())
            }
            user!.authentication.do {authentication, error in
                guard error == nil else {
                    print("error with refreshing completion handler: \(error?.localizedDescription)")
                    completionHandler(nil, error)
                    return}
                
                guard let authentication = authentication else {return}
                
                let service = GTLRClassroomService()
                service.authorizer = authentication.fetcherAuthorizer()
                let query = GTLRClassroomQuery_CoursesStudentsList.query(withCourseId: courseID)
                service.executeQuery(query){ticket, filelist, error in
                    if error != nil {
                        
                        completionHandler(nil, error)
                        print("error fetching students: \(error?.localizedDescription)")
                    }
                    
                    if let studentlist = filelist as? GTLRClassroom_ListStudentsResponse {
                        print("studentlist: \(studentlist)")
                        completionHandler(studentlist.students?.contains(where: {$0.userId == user!
                            .userID!}), nil)
                    }
                }
                
                
            }
        }
    }
}
func fetchclasses(Courses: Binding<[GTLRClassroom_Course]>, showsheet: Binding<Bool>, completionHander: @escaping (GIDGoogleUser? , Error?) -> Void){
    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
      if error != nil || user == nil {
          let config = GIDConfiguration(clientID: "342162894109-jf2fc1h8l2oe75vj05qn11mipcrhj56h.apps.googleusercontent.com")
          GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController(), hint: "", additionalScopes: ["https://www.googleapis.com/auth/classroom.coursework.students", "https://www.googleapis.com/auth/classroom.courses","https://www.googleapis.com/auth/classroom.rosters", "https://www.googleapis.com/auth/classroom.coursework.me"]){  user, error in
              guard error == nil else {
                  print("sign in failed with error: \(error!.localizedDescription)")
                  return}
              guard let user = user else{return}
              user.authentication.do{authentication, error in
                  guard error == nil else {
                      print("error with calling API: \(error?.localizedDescription)")
                      completionHander(nil, error)
                      return
                  }
                  guard let authentication = authentication else {
                      print("error with setting authentication")
                      return
                  }
                  
                  print("making API call")
                  
                  let service = GTLRClassroomService()
                  service.authorizer = authentication.fetcherAuthorizer()
                  let query = GTLRClassroomQuery_CoursesList.query()
                  service.executeQuery(query) {ticket, filelist, error in
                      if error != nil {
                          print("error calling API: \(error?.localizedDescription)")
                          completionHander(nil, error)
                      }
                      else {
                          print("received data: \(filelist)")
                          if let list = filelist as? GTLRClassroom_ListCoursesResponse {
                              if list.courses != nil {
                                  for course in list.courses! {
                                      isTeacher(courseID: course.identifier!) { isteacher, error in
                                          guard error == nil, isteacher != nil else {
                                              
                                              return
                                          }
                                          if isteacher! && !Courses.wrappedValue.contains(course) {
                                              Courses.wrappedValue.append(course)
                                          }
                                      }
                                  }
                                  showsheet.wrappedValue.toggle()
                                  completionHander(user, nil)
                              }
                          }
                      }
                      
                  }
                  
              }
          }
      }
        else {
            let grantedScopes = user?.grantedScopes
            if grantedScopes == nil || !grantedScopes!.contains("https://www.googleapis.com/auth/classroom.coursework.students") || !grantedScopes!.contains("https://www.googleapis.com/auth/classroom.courses"){
                //requesting additional scopes to create coursework
                let additionalScopes = ["https://www.googleapis.com/auth/classroom.coursework.students", "https://www.googleapis.com/auth/classroom.courses"]
                GIDSignIn.sharedInstance.addScopes(additionalScopes, presenting: getRootViewController())
            }
            user?.authentication.do{authentication, error in
                guard error == nil else {
                    print("error with calling API: \(error?.localizedDescription)")
                    return
                }
                guard let authentication = authentication else {
                    print("error with setting authentication")
                    return
                }
                
                print("making API call")
                
                let service = GTLRClassroomService()
                service.authorizer = authentication.fetcherAuthorizer()
                let query = GTLRClassroomQuery_CoursesList.query()
                service.executeQuery(query) {ticket, filelist, error in
                    if error != nil {
                        print("error calling API: \(error?.localizedDescription)")
                    }
                    else {
                        if let list = filelist as? GTLRClassroom_ListCoursesResponse {
                            if list.courses != nil {
                                for course in list.courses! {
                                    if course.ownerId! == user?.userID! && !Courses.wrappedValue.contains(course){
                                        Courses.wrappedValue.append(course)
                                    }
                                }
                                showsheet.wrappedValue.toggle()
                            }
                        }
                    }
                    
                }
                
            }
        }
    }
}

func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        return root
}
extension View {
    func halfSheet<SheetView: View>(showsheet: Binding<Bool>, @ViewBuilder sheetView: @escaping () -> SheetView) -> some View {
        
        return self
            .background(
                HalfSheetHelper(sheetView: sheetView(), showSheet: showsheet)
            )
    }
    
    func PopUpNavigationViewController<Content: View>(HorizontalPadding: CGFloat = 40, show: Binding<Bool>,exerciseList: Binding<[String]>, repslist: Binding<[String]>, ColorScheme: ColorScheme, @ViewBuilder content: @escaping () -> Content)->some View{
        return self
            .overlay {
                if show.wrappedValue {
                    GeometryReader{proxy in
                        let size = proxy.size
                        VStack {
                            content()
                        }
                        .frame(width: size.width - HorizontalPadding, height: size.height , alignment: .center)
                        .cornerRadius(15)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(ColorScheme == .dark ? Color(.systemGray5) : .white)
                                .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
                        }
                    }
                }
            }
    }
    
    func EditExercisePopUp<Content: View>(EditingExercise: Binding<Bool>, index: Int, ColorScheme: ColorScheme, @ViewBuilder content: @escaping () -> Content)-> some View {
        return self
            .overlay {
                if EditingExercise.wrappedValue {
                    VStack {
                        content()
                    }
                    .frame(width: 360, height: 200)
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(ColorScheme == .dark ? Color(.systemGray5) : .white)
                            .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
                    }
                }
            }
    }
    
    func PopUp<Content: View>(Horizontalpadding: CGFloat = 40, show: Binding<Bool>, ColorScheme: ColorScheme,  @ViewBuilder content: @escaping () -> Content)-> some View {
        return self
            .overlay {
                
                if show.wrappedValue {
                        VStack {
                            content()
                        }
                        .transition(.scale.combined(with: .opacity))
                }
            }
    }
    
}

struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    var sheetView: SheetView
    @Binding var showSheet: Bool
    let controller = UIViewController()
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.view.backgroundColor = .clear
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        if showSheet {
            let sheetController = CustomHostingController(rootView: sheetView)
            
            uiViewController.present(sheetController,animated: true) {
                DispatchQueue.main.async {
                    self.showSheet.toggle()
                }
            }
        }
        
    }
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        
        if let presentationController = presentationController as? UISheetPresentationController {
            
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    
    var items: [Any]
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}


struct halfsheetView: View {
    @Binding var courses: [GTLRClassroom_Course]
    @State var AssignmentTitle: String = ""
    @State var AssignmentDescription: String = ""
    @State var openedClassroom: Bool = false
    @State var AssignmentPoints: String = ""
    @State var DueDate: Date = Date()
    @State var workout: Workout = Workout(name: "", creator: "", time: 30, description: "", Sets: 2, difficulty: .Intermediate)
    @State var DynamicLink: String = ""
    @State var Coursework: GTLRClassroom_CourseWork?
    @State var courseworkID: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Share to Classroom")
                    .font(.custom("GothamMedium", size: 20))
                    .padding(.top, 10)
                ForEach(courses, id: \.self) {course in
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .foregroundColor(Color.init(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48())))
                        VStack {
                            HStack {
                                Text(course.name!)
                                    .font(.custom("GothamMedium", size: 25))
                                    .padding([.leading, .top], 10)
                                    .foregroundColor(.white)
                                Spacer()
                                    
                            }
                            Spacer()
                        }
                        
                        
                    }
                    .frame(width: 350, height: 75)
                    .onTapGesture {
                        openedClassroom.toggle()
                    }
                    .navigationDestination(isPresented: $openedClassroom) {
                        ScrollView {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("Create Assignment")
                                        .font(.custom("GothamMedium", size: 20))
                                    
                                    Button {
                                        let points = NumberFormatter().number(from: AssignmentPoints)
                                        AssignWorkout(courseworkID: courseworkID, Title: AssignmentTitle, Description: AssignmentDescription, DueDate: DueDate, dynamicLink: DynamicLink, maxPoints: points!, courseID: course.identifier!)
                                    } label: {
                                        
                                        if !AssignmentTitle.isEmpty && !AssignmentDescription.isEmpty && !AssignmentPoints.isEmpty {
                                            Text("Assign")
                                                .font(.custom("GothamMedium", size: 25))
                                                .padding(15)
                                                .background(.blue)
                                                .foregroundColor(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                        }
                                        else {
                                            Text("Assign")
                                                .font(.custom("GothamMedium", size: 25))
                                                .padding(15)
                                                .background(Color(.systemGray5))
                                                .foregroundColor(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                        }
                                    }
                                    .padding([.trailing, .top], 10)
                                    .disabled(AssignmentTitle.isEmpty || AssignmentDescription.isEmpty || AssignmentPoints.isEmpty)

                                }
                                
                                VStack(alignment: .leading, spacing: 8){
                                    Text("Assignment Title")
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    
                                    TextField("Today's Workout Assignment", text: $AssignmentTitle)
                                        .font(.custom("Gotham-Bold", size: 25))
                                        .padding(.top, 5)
                                    Divider()
                                }.padding(.top, 25)
                                
                                
                                VStack(alignment: .leading, spacing: 8){
                                    Text("Assignment Description")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    
                                    TextField("workout description", text: $AssignmentDescription)
                                        .font(.custom("Gotham Regular", size: 20))
                                        .padding(.top, 5)
                                    Divider()
                                }.padding(.top, 20)
                                
                                HStack {
                                    HStack {
                                        Text("Points:")
                                            .fontWeight(.regular)
                                        TextField("100", text: $AssignmentPoints)
                                            .keyboardType(.numberPad)
                                            .frame(width: 100)
                                            
                                            
                                    }
                                    
                                    HStack {
                                        Text("Due Date")
                                            .fontWeight(.regular)
                                        
                                        DatePicker("", selection: $DueDate, in: Date()..., displayedComponents: .date)
                                        
                                        
                                    }
                                }.padding(.top, 20)
                                
                                Text("Attached Materials")
                                    .font(.custom("GothamMedium", size: 20))
                                    .padding(.top, 25)
                                
                                HStack {
                                    
                                    Image(systemName: "link")
                                        .frame(width: 20, height: 20)
                                    HStack {
                                        Image("kal splashscreen transparent bg 2")
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                        VStack {
                                            Text("New Workout Assignment")
                                                .font(.custom("GothamMedium", size: 15))
                                                .lineLimit(1)
                                            Text("\(DynamicLink)")
                                                .font(.custom("GothamLight", size: 10))
                                                .lineLimit(1)
                                        }
                                        
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.systemGray6), lineWidth: 1)
                                    )
                                }
                                
                                
                            }
                            .padding(.horizontal, 10)
                            .onAppear() {
                                courseworkID = UUID().uuidString
                                GenerateclassroomDynamicLink(workout: workout, course: course, courseworkID: courseworkID) { shortURL, LongURL, err in
                                    DynamicLink = shortURL!.absoluteString
                                    print("Dynamic link is \(DynamicLink)")
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}


func GenerateclassroomDynamicLink(workout: Workout, course: GTLRClassroom_Course, courseworkID: String, completionHandler : @escaping (URL?, URL?, Error?) -> Void){
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "fitable-fad30.firebaseapp.com"
    components.path = "/shareWorkout"
    var queryItemsarray: [URLQueryItem] = []
    let workoutIDQueryItem = URLQueryItem(name: "workoutID", value: workout.Name)
    let time = URLQueryItem(name: "time", value: "\(workout.Time)")
    let courseID = URLQueryItem(name: "CourseID", value: course.identifier!)
    let sets = URLQueryItem(name: "sets", value: "\(workout.sets)")
    let courseworkID = URLQueryItem(name: "CourseworkID", value: courseworkID)
    
    queryItemsarray.append(workoutIDQueryItem)
    queryItemsarray.append(time)
    queryItemsarray.append(courseworkID)
    queryItemsarray.append(courseID)
    queryItemsarray.append(sets)
    for exercise in workout.Exercises {
        queryItemsarray.append(URLQueryItem(name: "Exercise", value: exercise))
    }
    for rep in workout.reps {
        queryItemsarray.append(URLQueryItem(name: "Rep", value: rep))
    }
    queryItemsarray.append(URLQueryItem(name: "Type", value: "Assignment"))
    components.queryItems = queryItemsarray
    print("\(queryItemsarray)")
    guard let linkParameters = components.url else {return}
    
    
    guard let shareLink = DynamicLinkComponents.init(link: linkParameters, domainURIPrefix: "https://fitable.page.link") else {
        print("couldn't create FDL components")
        return}
    
    
    shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
    shareLink.iOSParameters?.appStoreID = "1638553640"
    shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
    shareLink.socialMetaTagParameters?.title = "\(workout.Name)"
    shareLink.socialMetaTagParameters?.descriptionText = "\(workout.Description)"
    
    guard let longURL = shareLink.url else {
        print("problem unwrapping long uRL")
        
        return}
    print("the long dynamic link is \(longURL.absoluteString)")
    shareLink.shorten { (url, warning, error) in
        if let error = error {
            completionHandler(nil, nil , error)
            print("OH no! got an error \(error.localizedDescription)")
            return
        }
        if let warning = warning {
            for warning in warning {
                print("FDL warning: \(warning)")
            }
        }
        
        guard let url = url else {
            print("error with url")
            return
        }
        
        print("I have a short URL to share \(url.absoluteString)")
        completionHandler(url, longURL, nil)
    }
    
}


func AssignWorkout(courseworkID: String, Title: String, Description: String, DueDate: Date, dynamicLink: String, maxPoints: NSNumber, courseID: String) {
    let coursework = GTLRClassroom_CourseWork()
    coursework.identifier = courseworkID
    coursework.title = Title
    coursework.descriptionProperty = Description
    coursework.maxPoints = maxPoints
    coursework.courseId = courseID
    let ClassroomLink = GTLRClassroom_Link()
    ClassroomLink.title = "Workout Assignment"
    ClassroomLink.url = dynamicLink
    let Classroommaterial = GTLRClassroom_Material()
    Classroommaterial.link = ClassroomLink
    coursework.materials = [Classroommaterial]
    coursework.state = "PUBLISHED"
    coursework.workType = "Assignment"
    
    let query = GTLRClassroomQuery_CoursesCourseWorkCreate.query(withObject: coursework, courseId: courseID)
    
    GIDSignIn.sharedInstance.restorePreviousSignIn() {user, error in
        user!.authentication.do { authentication, error in
            print("executed authentication")
            guard error == nil else {
                print("error fetching access token: \(error?.localizedDescription)")
                return
            }
            guard let authentication = authentication else {return}
            let classroomservice = GTLRClassroomService()
            classroomservice.authorizer = authentication.fetcherAuthorizer()
            
            classroomservice.executeQuery(query) {ticket, filelist, error in
                if error != nil {
                    print("Error assigning students: \(error?.localizedDescription)")
                }
                print(filelist)
            }
        }
    }

}

func GenerateSubmissionLink(StudentName: String, WorkoutAccuracy: String, WorkoutExercises: [String], ExerciseAccuracy: [String], Comments: [String], CourseID: String, completionHandler: @escaping (URL?, Error?) -> Void) {
    var submissionID = ""
    var sum = 0
    for _ in 0...10 {
        let randomNum = Int.random(in: 1...10)
        submissionID += "\(randomNum)"
        sum += randomNum
    }
    submissionID += "\(sum)"
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "fitable-fad30.firebaseapp.com"
    components.path = "/Submissions"
    
    var queryparameters: [URLQueryItem] = []
    queryparameters.append(URLQueryItem(name: "SubmissionID", value: submissionID))
    queryparameters.append(URLQueryItem(name: "Name", value: StudentName))
    queryparameters.append(URLQueryItem(name: "OverallAccuracy", value: WorkoutAccuracy))
    queryparameters.append(URLQueryItem(name: "CourseID", value: CourseID))
    for exercise in WorkoutExercises {
        queryparameters.append(URLQueryItem(name: "Exercise", value: exercise))
    }
    for accuracy in ExerciseAccuracy {
        queryparameters.append(URLQueryItem(name: "Accuracy", value: accuracy))
    }
    for comment in Comments {
        queryparameters.append(URLQueryItem(name: "Comment", value: comment))
    }
    queryparameters.append(URLQueryItem(name: "Type", value: "Submission"))
    components.queryItems = queryparameters
    
    guard let linkParameter = components.url else {return}
    print("Submission link: \(linkParameter)")
    guard let shareLink = DynamicLinkComponents(link: linkParameter, domainURIPrefix: "https://fitable.page.link") else {
        print("Couldn't create FDL components")
        return
    }
    
    if let BundleID = Bundle.main.bundleIdentifier {
        shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: BundleID)
    }
    shareLink.iOSParameters?.appStoreID = "1638553640"
    shareLink.shorten { url, warnings, error in
        if let error = error {
            
            print("Oh no ! Got an error \(error.localizedDescription)")
            completionHandler(nil, error)
            return
        }
        if let warnings = warnings {
            for warning in warnings {
                print("FDL warning : \(warning)")
            }
            
        }
        
        guard let url = url else {
            return
        }
        completionHandler(url, nil)
    }
}


func SubmitAssignment(CourseWorkID: String, CourseID: String, WorkoutExercises: [String], ExerciseAccuracy: [String], Comments: [String], StudentName: String, workoutAccuracy: String, comments: [String]){
    
    let submissionRequest = GTLRClassroom_TurnInStudentSubmissionRequest()
    let modifyAttachmentRequest = GTLRClassroom_ModifyAttachmentsRequest()
    GenerateSubmissionLink(StudentName: StudentName, WorkoutAccuracy: workoutAccuracy, WorkoutExercises: WorkoutExercises, ExerciseAccuracy: ExerciseAccuracy, Comments: comments, CourseID: CourseID) { dynamiclink, error in
        guard error == nil else {
            print("Error found in generating submission link: \(error!.localizedDescription)")
            return
        }
        
        let submissionLink = GTLRClassroom_Link()
        submissionLink.url = dynamiclink?.absoluteString
        let submissionAttachment = GTLRClassroom_Attachment()
        submissionAttachment.link = submissionLink
        modifyAttachmentRequest.addAttachments = [submissionAttachment]
        GIDSignIn.sharedInstance.restorePreviousSignIn() {user, error in
            user!.authentication.do {authentication, error in
                guard error == nil else {
                    print("error refreshing access token")
                    return}
                guard let authentication = authentication else {
                    return
                }
                let classroomservice = GTLRClassroomService()
                classroomservice.authorizer = authentication.fetcherAuthorizer()
                let query = GTLRClassroomQuery_CoursesCourseWorkStudentSubmissionsTurnIn.query(withObject: submissionRequest, courseId: CourseID, courseWorkId: CourseWorkID, identifier: (user?.userID!)!)
                let modifyattachment = GTLRClassroomQuery_CoursesCourseWorkStudentSubmissionsModifyAttachments.query(withObject: modifyAttachmentRequest, courseId: CourseID, courseWorkId: CourseWorkID, identifier: user!.userID!)
                
                classroomservice.executeQuery(modifyattachment)
                classroomservice.executeQuery(query)
                
            }
        }
    }
}


struct StudentSubmissionResultsview: View {
    @State var studentName: String
    @Binding var workoutResults: WorkoutResults
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading) {
                    Text("Workout Results")
                        .font(.custom("Gotham Regular", size: 20))
                    Text(studentName)
                        .font(.custom("GothamMedium", size: 35))
                }
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 25)
                        .frame(width: 360, height: 150)
                        .foregroundColor(colorScheme == .dark ? Color(.systemGray5) : .white)
                        .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
                    
                    VStack(alignment: .leading){
                        Text("Overall Accuracy")
                            .font(.custom("Gotham Regular", size: 20))
                        Text("\(workoutResults.overallAccuracy)%")
                            .font(.custom("GothamMedium", size: 50))
                    }.padding(.leading, 15)
                }
                
                VStack(alignment:.leading) {
                    ForEach(workoutResults.Exercises.indices){ i in
                        VStack {
                            HStack {
                                Text(workoutResults.Exercises[i])
                                    .font(.custom("GothamMedium", size: 25)
                                    )
                                Spacer()
                                exerciseAccuracyView(accuracy: workoutResults.ExerciseAccuracy[i])
                            }
                            Divider()
                        }.padding(.top, 15)
                        
                    }
                }
                
                .padding(10)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(colorScheme == .dark ? Color(.systemGray5) : .white)
                        .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
                        .frame(maxWidth: 360)
                }
                
                VStack(alignment: .leading) {
                    Text("Comments")
                        .font(.custom("GothamMedium", size: 20))
                    
                    ForEach(workoutResults.comments, id: \.self) {comment in
                        Text(comment)
                            .font(.custom("Gotham Regular", size: 25))
                            .padding(.top, 2)
                    }
                    .padding(.top, 15)
                }
                .padding(15)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(colorScheme == .dark ? Color(.systemGray5) : .white)
                        .shadow(color: Color(.systemGray3), radius: 5, x: 0, y: 5)
                        .frame(maxWidth: 360)
                }
                .padding(.top, 20)
            }
        }
    }
}
 

struct exerciseAccuracyView: View {
    @State var progress: Float = 0.0
    @State var accuracy: Int
    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 15.0)
                    .opacity(0.20)
                    .foregroundColor(Color.gray)
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.init(red: drand48(), green: drand48(), blue: drand48()))
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeInOut(duration: 1.0), value: self.progress)
            }.padding(.all, 15)
            
            VStack {
                Text("\(accuracy)%")
                    .font(.custom("GothamMedium", size: 35))
                Text("accuracy")
                    .font(.custom("Gotham Regular", size: 20))
                    .opacity(0.75)
            }
        }
        .frame(minWidth: 150, maxWidth: 150, minHeight: 150,maxHeight: 150)
        .onAppear() {
            if self.accuracy != 0 {
                self.progress = Float(self.accuracy) / Float(100)
                print("progress : \(self.progress)")
            }
        }
    }
}
