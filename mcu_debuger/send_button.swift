//
//  send_button.swift
//  mcu_debuger
//
//  Created by TaigaTakano on 2024/03/09.
//

import Foundation
import SwiftUI

struct ShareButton: View {
    @ObservedObject var udp_agent : UDPAgent
    @ObservedObject var joystick_value : JoystickValue
    
    @State var SendingTimer : Timer!
    var body: some View {
        if udp_agent.ip != "" && udp_agent.port != "" && Int(udp_agent.port)! < 65535 && Int(udp_agent.port)! > 49152 {
            ShareButtonUI(udp_agent: udp_agent)
                .onTapGesture {
                    if udp_agent.ip != "" && udp_agent.port != "" && Int(udp_agent.port)! < 65535 && Int(udp_agent.port)! > 49152 {
                        udp_agent.IsSending.toggle()
                        if udp_agent.IsSending{
                            UDPTimerStart()
                            udp_agent.send(String("INFOREQ").data(using: .utf8)!)
                        }else{
                            UDPTimerStop()
                        }
                    }
                }
                .opacity(udp_agent.ip != "" && udp_agent.port != "" && Int(udp_agent.port)! < 65535 && Int(udp_agent.port)! > 49152 ? 1.0 : 0.8)
        }
        else{
            ShareButtonUI(udp_agent: udp_agent)
                .opacity(0.5)
        }
    }
    
    func UDPTimerStart(){
        SendingTimer?.invalidate()
        SendingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){
            _ in
            udp_agent.send(String(joystick_value.YControllerPower).data(using: .utf8)!)
        }
    }
    
    func UDPTimerStop(){
        SendingTimer?.invalidate()
        SendingTimer = nil
    }
}

struct ShareButtonUI: View {
    @ObservedObject var udp_agent : UDPAgent
    var body: some View {
        VStack{
            Spacer()
            ZStack {
                if udp_agent.IsSending{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .frame(height: 70.0)
                        .foregroundColor(.blue)
                }else{
                    RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        .frame(height: 70.0)
                        .foregroundColor(.gray)
                        .opacity(0.7)
                }
                
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.white)
                    .font(Font.title.weight(.bold))
            }
            .padding(.horizontal)
        }
        
    }
}
