//
//  Analyticsview.swift
//  Fitable
//
//  Created by Kiran Lim on 6/8/22.
//

import SwiftUI
import Charts
import Firebase
import MobileCoreServices
import FirebaseAuth


struct Analyticsview: View {
    @State var userdatafile: User = User(username: "", Email: "", Joindate: "", Userleague: .bronze)
    @State var Dayselected: Days = Days(Day: "Mon", Date: Date.now)
    @State var currentActiveItem: Hour?
    @State var plotWidth: CGFloat = 0
    @State var calories: Int = 250
    @Environment(\.colorScheme) var colourScheme
    let columns = [GridItem(.flexible(), spacing: 45)]
    @State var fromIndex: (Int, Int) = (110, 110)
    @State var toIndex: (Int, Int) = (110, 110)
    @State var currentWidget: String?
    
    @State var showViews: [Bool] = Array(repeating: false, count: 10)
    @State var showViewIndex: Int = 0
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hi \(userdatafile.Username)")
                            .font(.custom("GothamLight", size: 25))
                        Text("This is your progress")
                            .font(.custom("GothamMedium", size: 30))
                    }
                    Spacer()
                }
                .padding(.leading, 15)
                
                ScrollViewReader {proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(userdatafile.ExerciseData) {day in
                                Text(extractDate(date: day.date))
                                    .fontWeight(Calendar.current.isDate(Dayselected.date, inSameDayAs: day.date) ? .bold : .semibold)
                                    .foregroundColor(Calendar.current.isDate(Dayselected.date, inSameDayAs: day.date) ? .white : colourScheme == .dark ? .white : .black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Calendar.current.isDate(Dayselected.date, inSameDayAs: day.date) ? 6 : 0)
                                    .padding(.horizontal, Calendar.current.isDate(Dayselected.date, inSameDayAs: day.date) ? 12 : 0)
                                    .frame(width: Calendar.current.isDate(Dayselected.date, inSameDayAs: day.date) ? 140 : nil)
                                    .background {
                                        Capsule()
                                            .foregroundColor(Color(.systemPurple))
                                            .opacity(Calendar.current.isDate(Dayselected.date, inSameDayAs: day.date) ? 0.8 : 0)
                                    }
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            proxy.scrollTo(day.id, anchor: .center)
                                            
                                        }
                                        Dayselected = day
                                    }
                                    .id(day.date.formatted(.dateTime.day()))
                                    .animation(.spring(), value: Dayselected)
                                
                            }
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 25)
                
                
                if Dayselected.calories != 0 {
                    
                    AnimatedChart(DaySelected: $Dayselected)
                    
                }
                else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundColor(Color(.systemGray5))
                                .frame(width: 355, height: 200)
                            Text("No Activity Recorded that Day")
                                .font(.custom("GothamMedium", size: 20))
                        }
                        .opacity(showViews[0] ? 1 : 0)
                        .offset(y: showViews[0] ? 0 : 250)
                    
                    
                }
                HStack{
                    caloriesWidget(userdatafile: $userdatafile, calories: $Dayselected.calories, size: CGSize(width: 375, height: 667))
                    
                    HeartRateWidget(Dayselected: $Dayselected, userdatafile: $userdatafile, geo: CGSize(width: 375, height: 667))
                }
                .opacity(showViews[1] ? 1 : 0)
                .offset(y: showViews[1] ? 0 : 200)
                
                PieChartView(colors: [Color.red, Color.green, Color.blue, Color.purple, Color.orange, Color.gray], geometry: CGSize(width: 375, height: 667), Dayselected: $Dayselected, formatter: {value in String(format: "%.1f min", value)})
                    .opacity(showViews[2] ? 1 : 0)
                    .offset(y: showViews[2] ? 0 : 250)
                
                StepsWidget(dayselected: $Dayselected, userdatafile: $userdatafile, geo: CGSize(width: 375, height: 667))
                    .opacity(showViews[3] ? 1 : 0)
                    .offset(y: showViews[3] ? 0 : 200)
                
                
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
            Dayselected = userdatafile.currentDay!
            var delay = 0.0
            withAnimation(.easeInOut) {
                showViews[0] = true
            }
            withAnimation(.easeInOut.delay(0.1)) {
                showViews[1] = true
            }
            withAnimation(.easeInOut.delay(0.15)) {
                showViews[2] = true
            }
            withAnimation(.easeInOut.delay(0.2)) {
                showViews[3] = true
            }
            withAnimation(.easeInOut.delay(0.35)) {
                showViews[4] = true
            }
            withAnimation(.easeInOut.delay(0.50)) {
                showViews[5] = true
            }
        }
    }
    func extractDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = (Calendar.current.isDate(Dayselected.date, inSameDayAs: date) ? "dd MMM" : "dd")
        return (Calendar.current.isDate(.now, inSameDayAs: date) && Calendar.current.isDate(Dayselected.date, inSameDayAs: date) ? "Today " : "") + formatter.string(from: date)
    }
}

struct Analyticsview_Previews: PreviewProvider {
    static var previews: some View {
        Analyticsview()
    }
}

