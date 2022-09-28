//
//  Realm.swift
//  Fitable
//
//  Created by Kiran Lim on 24/7/22.
//

import Foundation
import RealmSwift
import FirebaseAuth

let userdata = userdatarealm()
struct Constants {
    static let REALM_APP_ID = "fitable-stoqa" // <- update this with your Realm App ID
    
}

class userdatarealm {
    
    var realm: Realm
    
    init() {
        
        let username = "userdata"
        
        var config = Realm.Configuration(
            schemaVersion: 13,
            
            migrationBlock: {migration, oldSchemaVersion in
                if (oldSchemaVersion < 13) {
                    
                }
            })
        
        
        config.fileURL!.deleteLastPathComponent()
        config.fileURL!.appendPathComponent(username)
        config.fileURL!.appendPathExtension("realm")
        Realm.Configuration.defaultConfiguration = config
        self.realm = try! Realm(configuration: config)
    }
}




class AppState: ObservableObject {
    @Published var target: TargetUI = .loggedIn
    @Published var resolver: MultiFactorResolver = MultiFactorResolver()
    @Published var verificationID: String? = ""
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    
    @Published var chosenExercise: String = ""
    @Published var exerciseType: String = ""
    
    @Published var TimeTotal: CGFloat = 0
    
    @Published var CourseID: String = ""
    @Published var CourseWorkID: String = ""
    @Published var StudentName: String = ""
    
    @Published var breaktimeleft: String = ""

    
    private var handle : AuthStateDidChangeListenerHandle?
    
    func listen() {
        guard handle == nil else {return}
        if Auth.auth().currentUser == nil {
            self.target = .loggedOut
        }
        handle = Auth.auth().addStateDidChangeListener {auth, user in
            if user != nil && user?.isEmailVerified == true {
                self.target = .loggedIn
            }
            if user != nil && user?.isEmailVerified == false {
                self.target = .loggedOut
            }
            if user == nil {
                self.target = .loggedOut
            }
            
        }
    }
    var context: Any = ""
    
}
enum TargetUI: Int {
    case none
    case loggedOut
    case loginComplete
    case loggedIn
    case password
    case GoogleSignIn
    case SignUp
    case Verification
    case PoseEstimation
    case workoutresults
    case Workout
    case Break
}

enum league: String, PersistableEnum {
    case bronze
    case silver
    case gold
}

enum Workoutdifficultyenum: String, PersistableEnum {
    case Beginner
    case Intermediate
    case Advanced
}

struct WorkoutResults {
    var overallAccuracy: Int
    var Exercises: [String]
    var ExerciseAccuracy: [Int]
    var comments: [String]
}
class Workout: Object, Identifiable{
    @Persisted var id = UUID()
    @Persisted var Name: String
    @Persisted var Creator: String
    @Persisted var Time: Int
    @Persisted var Exercises = List<String>()
    @Persisted var reps = List<String>()
    @Persisted var tag = List<String>()
    @Persisted var Description: String
    @Persisted var sets: Int
    @Persisted var likes: List<String>
    @Persisted var dislikes: List<String>
    @Persisted var Difficulty = Workoutdifficultyenum.Beginner
    @Persisted var image: Data
    @Persisted var type: String
    
    convenience init(name: String, creator: String, time: Int, description: String, Sets: Int, difficulty: Workoutdifficultyenum) {
        self.init()
        Name = name
        Creator = creator
        Time = time
        Difficulty = difficulty
    }
    
}

enum ExerciseType: String, PersistableEnum {
    case cardio = "cardio"
    case strengthtraining = "strengthtraining"
    case flexibility = "flexibility"
    case Balance = "Balance"
    case Coordination = "Coordination"
    case Yoga = "Yoga"
    case Pilates = "Pilates"
}

class Exercise: Object, Identifiable{
    @Persisted var id = UUID()
    @Persisted var name: String
    @Persisted var repsdonetoday: Int
    @Persisted var timespent: Float
    @Persisted var iconImgName: String
    @Persisted var fullsizeImgName: String
    @Persisted var exerciseType: ExerciseType
    
    convenience init(name: String, iconimgName: String, fullsizeImgName: String, exerciseType: ExerciseType) {
        self.init()
        self.name = name
        self.repsdonetoday = 0
        self.timespent = 0
        self.iconImgName = iconimgName
        self.fullsizeImgName = fullsizeImgName
        self.exerciseType = exerciseType
    }
}//cheng rui was here




enum Exercises: String{
    case Squats = "Squats"
    case JumpingJacks = "Jumping Jacks"
    case Burpees = "Burpees"
    case Pushups = "Pushups"
    case SingleLegDeadlifts = "Single Leg Deadlifts"
}


class Hour: Object, Identifiable{
    @Persisted var id = UUID()
    @Persisted var calories: Int
    @Persisted var HeartRate: Int
    @Persisted var hour: String
    @Persisted var animate: Bool = false
    
    convenience init(Hour: String) {
        self.init()
        hour = Hour
        calories = 0
    }
}

class Days: Object, Identifiable{
    @Persisted var id = UUID()
    @Persisted var day: String
    @Persisted var date: Date
    @Persisted var calories: Int
    @Persisted var calorieshour: List<Hour>
    @Persisted var HeartRate: Int
    @Persisted var steps: Float
    @Persisted var animate: Bool = false
    @Persisted var exercises: List<Exercise>
    convenience init(Day: String, Date: Date) {
        self.init()
        day = Day
        calories = 0
        calorieshour = List<Hour>()
        date = Date
    }
}

var workoutexericselist: [String] = ["Squats",  "Jumping Jacks", "Burpees", "Pushups", "Single Leg Deadlifts", "Break"]
var exerciselist: [Exercise] = [Exercise(name: "Squats", iconimgName: "Squats", fullsizeImgName: "Squats", exerciseType: .cardio),
                            
                            Exercise(name: "Jumping Jacks", iconimgName: "Jumping Jacks", fullsizeImgName: "Jumping Jacks", exerciseType: .cardio),
                            Exercise(name: "Pushups", iconimgName: "Pushups", fullsizeImgName: "Pushups", exerciseType: .flexibility),
                            Exercise(name: "Burpees", iconimgName: "Burpees", fullsizeImgName: "Burpees", exerciseType: .flexibility),
                            Exercise(name: "Single Leg Deadlifts", iconimgName: "Single-Leg Deadlifts", fullsizeImgName: "Single-Leg Deadlifts", exerciseType: .Balance)
]

struct Months : Identifiable, Hashable {
    var id = UUID()
    var month: String
    var calories: Int
    var animate: Bool = false   
}

class User: Object, Identifiable {
    @Persisted var Username: String
    @Persisted var email: String
    @Persisted var joindate: String
    @Persisted var userleague = league.bronze
    @Persisted var Workouts: List<Workout>
    @Persisted var profilepic: Data
    @Persisted var money = 0
    @Persisted var ExerciseData: List<Days>
    @Persisted var currentDay: Days?
    @Persisted var ExerciseDataMax: Int
    @Persisted var caloriesgoal: Int = 500
    @Persisted var HeartrateGoal: Int = 200
    @Persisted var StepsGoal: Float = 10000
    @Persisted var WeeklyCalories: Int = 0
    convenience init(username: String, Email: String, Joindate: String, Userleague: league) {
        self.init()
        Username = username
        email = Email
        joindate = Joindate
        userleague = Userleague
        ExerciseDataMax = 7
    }
}
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}



