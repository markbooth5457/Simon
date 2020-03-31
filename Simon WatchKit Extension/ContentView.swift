//
//  ContentView.swift
//  Simon WatchKit Extension
//
//  Created by Mark Booth on 22/03/2020.
//  Copyright © 2020 Mark Booth. All rights reserved.
//

import SwiftUI

enum Say : String, CaseIterable {
    case red
    case yellow
    case green
    case blue
}

class SimonSpeaks: ObservableObject {
    @Published var word : Say = .blue
    @Published var siSpeaking = false
     var wordList : [Say] = []
    func append(newWord : Say) {
        wordList.append(newWord)
    }
    
    func addRead() {
        append(newWord: Say.allCases.randomElement() ?? .red)
        readAloud()
    }
    
    func clear() {
        wordList = []
    }
    
    func restart(){
        self.clear()
        self.addRead()
    }
    
    func readAloud() {
        self.siSpeaking.toggle()
        if self.wordList.count > 0 {
            for i in 0 ..< wordList.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i + 1) * 1.25) {
                    self.word = self.wordList[i]
                    playEnum(word: self.word)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(self.wordList.count + 1) * 1.25) {
            self.siSpeaking.toggle()
        }
    }
    func iSay(color : Say, at : Int) -> Bool {
        return wordList[at] == color
    }
}

func playEnum(word : Say){
    switch word {
        case .blue :
            playSound(sound: "Tink", type: "aiff")
        case .green :
            playSound(sound: "Submarine", type: "aiff")
        case .red :
            playSound(sound: "Glass", type: "aiff")
        case .yellow :
            playSound(sound: "Ping", type: "aiff")
    }
}


struct ContentView: View {
    @ObservedObject var reader = SimonSpeaks()
    @State var score = 0
    @State var hiScore = 0
    @State var slipUp = false
    @State var this = 0

    fileprivate func buttonPress(say: Say, sound: String ) {
        playSound(sound: sound, type: "aiff")
        if self.reader.wordList.count > 0 &&
            self.reader.iSay(color: say, at: self.this) {
            self.score += 1
            self.this += 1
            if self.this == self.reader.wordList.count { //matched last in list, so add another
                self.this = 0
                self.reader.addRead()
            }
        } else { // match failed
            self.slipUp.toggle()
        }
    }
    
    var body: some View {
        VStack {
            Text("Simon says...\(score == 0 ? "tap text to begin" : score.description)")
                .onTapGesture(count: 1){
                    self.score = 0
                    self.this = 0
                    self.reader.restart()
                }

            VStack{
                HStack {
                    Button(action: {
                        self.buttonPress(say: .red, sound: "Glass" )
                    }, label: {
                        Image(systemName: "hexagon")
                        
                    })
                    .background(Color.red)
                        .clipShape(Capsule())
                        .scaleEffect(reader.word == .red && reader.siSpeaking ? 1.25 : 1.0)
                        
                    Button(action: {
                        self.buttonPress(say: .yellow, sound: "Ping" )

                    }, label: {
                         Image(systemName: "square")
                   })
                    .background(Color.yellow)
                        .clipShape(Capsule())
                    .scaleEffect(reader.word == .yellow && reader.siSpeaking  ? 1.25 : 1.0)
                }
                HStack {
                    Button(action: {
                        self.buttonPress(say: .green, sound: "Submarine" )
                    }, label: {
                        Image(systemName: "circle")

                    })
                        .background(Color.green)
                        .clipShape(Capsule())
                        .scaleEffect(reader.word == .green && reader.siSpeaking  ? 1.25 : 1.0)
                    Button(action: {
                        self.buttonPress(say: .blue, sound: "Tink" )
                    }, label: {
                        Image(systemName: "triangle")
                  
                    })
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .scaleEffect(reader.word == .blue && reader.siSpeaking  ? 1.25 : 1.0)

                }
           }
            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            .foregroundColor(reader.siSpeaking ? .gray : .black)
           .disabled(reader.siSpeaking)
        } .sheet(isPresented: $slipUp, onDismiss: {
            if self.score > self.hiScore {
                self.hiScore = self.score
            }
            self.score = 0
            self.this = 0
            self.reader.clear()
        }){
            Text("Oooppss!\nYou scored \(self.score)\nHigh Score: \(self.hiScore)")
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
