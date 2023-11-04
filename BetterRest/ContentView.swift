//
//  ContentView.swift
//  BetterRest
//
//  Created by stimLite on 04.11.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                
                Text(alertTitle)
                    .font(.title)
                Text(alertMessage)
                    .font(.headline)
                
                Form {
                    Section("When do you want to wake up?") {
                        
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            
                    }
                    
                    
                    Section("Desired amount of sleep") {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                            .onAppear{
                                calculateBedtime()
                            }
                            
                    }
                    
                    Section("Daily coffee intake") {
                        Picker("^[\(coffeeAmount + 1) cup](inflect: true)", selection: $coffeeAmount) {
                            ForEach(1..<20) { item in
                                Text("\(item )")
                                    .onAppear{
                                        calculateBedtime()
                                    }
                            }
                        }
                        Stepper("^[\(coffeeAmount + 1) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                    }
                }
                .navigationTitle("BetterRest")
//                .onAppear{
//                    calculateBedtime()
//                }
//                .toolbar {
//                    Button("Calculate", action: calculateBedtime)
//                }
//                .alert(alertTitle, isPresented: $showingAlert) {
//                    Button("OK") { }
//                } message: {
//                    Text(alertMessage)
//                }
            }
            .onAppear{
                calculateBedtime()
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let predication = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - predication.actualSleep
            
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
