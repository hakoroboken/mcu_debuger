//
//  udp_agent.swift
//  mcu_debuger
//
//  Created by TaigaTakano on 2024/03/09.
//

import Foundation
import Network

struct MWData : Identifiable{
    var id = UUID()
    var power: Int
    var time: Date
}

class UDPAgent: ObservableObject {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "timer", qos: .userInteractive)
    private var listener = try! NWListener(using: .udp, on: 64201)
    private var hoge_count = 0
    
    @Published var charts_data: [MWData] = []
    @Published var sensor_data = 0

    @Published var ip : String{
        didSet{
            UserDefaults.standard.set(ip , forKey: "UserIP")
        }
    }
    @Published var port : String {
        didSet{
            UserDefaults.standard.set(port , forKey: "UserPort")
        }
    }
    @Published var IsSending : Bool = false
    
    func send(_ payload: Data){
        if(self.ip != ""){
            self.connection = NWConnection(host: .init(self.ip), port: .init(integerLiteral: UInt16(self.port)! ), using: .udp)
            self.connection!.start(queue: queue)
            
            self.connection!.send(content: payload, completion: .contentProcessed({ sendError in
                
            }))
            Thread.sleep(forTimeInterval: 0.005)
            self.connection?.cancel()
        }
        else{
            self.IsSending = false
        }
    }
    
    init(){
        ip = UserDefaults.standard.string(forKey: "UserIP") ?? ""
        port = UserDefaults.standard.string(forKey: "UserPort") ?? ""
        self.listener.newConnectionHandler = {(newConnection) in
            newConnection.start(queue: self.queue)
            newConnection.receive(minimumIncompleteLength: 1, maximumLength: 256, completion: {(data,context,flag,error) in
                if let data = data{
                    DispatchQueue.main.async{
                        let str = String(data: data, encoding: .utf8) ?? ""
                        self.hoge_count += 1
                        let mwdata = MWData(power: (Int(str) ?? 0) / 19, time: Date())
                        NSLog(str)
                        self.charts_data.append(mwdata)
                        
                        if(self.charts_data.count > 100){
                            self.charts_data.removeFirst()
                        }
                        
                        self.sensor_data = (Int(str) ?? 0) / 19
                    }
                }
                newConnection.cancel()
            })
        }
        self.listener.start(queue: self.queue)
        
        self.charts_data.append(MWData(power: 0, time: Date()))
    }
}
