//
//  ContentView.swift
//  mcu_debuger
//
//  Created by TaigaTakano on 2024/03/09.
//

import SwiftUI
import Network
import Charts

struct ContentView: View {
    @ObservedObject var udp_agent = UDPAgent()
    @ObservedObject var joystick_value = JoystickValue()
    
    var body: some View {
        ZStack{
            Color.white
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .onTapGesture {
                    UIApplication.shared.closeKeyboard()
                }
            VStack{
                Spacer()
                Chart(udp_agent.charts_data) { dataRow in
                    LineMark(x: .value("time", dataRow.time), y: .value("power", dataRow.power))
                        .interpolationMethod(.catmullRom)
                }
                .frame(height:100)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .padding(.bottom, 200)
                
            }
   
            
            NetworkInfomationViews(udp_agent: udp_agent)
                .padding([.leading, .bottom, .trailing])
                .padding(.top, 20)
            
            ShareButton(udp_agent: udp_agent, joystick_value: joystick_value)
            
            YControllerView(JV: joystick_value)
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                .offset(y:-70)
            
            HStack{
                directionStatus(joystick_value: joystick_value)
                Spacer()
            }
            HStack{
                Spacer()
                sensorStatus(udp_agent: udp_agent)
            }
        }
        .onAppear(){
            udp_agent.charts_data.removeAll()
        }
        .onDisappear(){
            
        }
    }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct NetworkInfomationViews: View {
    @ObservedObject var udp_agent : UDPAgent
    @State var SendingText : String = "SENDING"
    @State var SuspendedText : String = "SUSPENDED"
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    var body: some View {
        VStack{
            Button(action:{
                if SendingText == "SENDING"{
                    SendingText = "Version " + version + " (Build " + build + ")"
                    SuspendedText = "Version " + version + " (Build " + build + ")"
                }else{
                    SendingText = "SENDING"
                    SuspendedText = "SUSPENDED"
                }
            }){
                HStack{
                    if udp_agent.IsSending{
                        Text(SendingText)
                            .font(.headline)
                            .foregroundColor(Color.gray)
                    }else{
                        Text(SuspendedText)
                            .font(.headline)
                            .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                }
            }
            TextField("0.0.0.0",text: $udp_agent.ip )
                .font(.title.weight(.semibold))
                .keyboardType(.decimalPad)
            TextField("0000",text: $udp_agent.port)
                .font(.title.weight(.semibold))
                .keyboardType(.decimalPad)
            Spacer()
        }
    }
}

struct directionStatus: View {
    @ObservedObject var joystick_value : JoystickValue
    var body: some View {
        
        
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                Text(String(joystick_value.YControllerPower))
                    .font(.system(size: 60))
                    .bold()
                    .padding(.leading, 40.0)
                Text("RPM")
                    .font(.system(size: 20))
                    .bold()
                    .padding(.leading, 40.0)
                    .baselineOffset(10)
                    .opacity(0.7)
                    .offset(x:-30)
            }
            Text("TARGET")
                .font(.headline)
                .opacity(0.7)
            
        }
        .padding(.bottom, 100)
    }
}

struct sensorStatus: View {
    @ObservedObject var udp_agent : UDPAgent
    var body: some View {
        
        
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                Text(String(udp_agent.sensor_data))
                    .font(.system(size: 60))
                    .bold()
                    .padding(.leading, 40.0)
                Text("RPM")
                    .font(.system(size: 20))
                    .bold()
                    .padding(.leading, 40.0)
                    .baselineOffset(10)
                    .opacity(0.7)
                    .offset(x:-30)
            }
            Text("SENSOR")
                .font(.headline)
                .opacity(0.7)
            
        }
        .padding(.bottom, 100)
    }
}

#Preview {
    ContentView()
}
