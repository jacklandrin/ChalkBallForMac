//
//  ContentView.swift
//  ChalkSeven
//
//  Created by jack on 2020/4/11.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI



struct ChalkSevenView: View {
    @EnvironmentObject var chessboard : Chessboard
    @State var newBallOffsetX: CGFloat = 0.0
    @State var lastNewBallOffsetX: CGFloat = 0.0
    @State var newBallOffsetY: CGFloat = newBallDefaultY
    @State var showRecord = false
    @State var muteBGM = false
    {
        didSet {
            muteBGM ? MusicHelper.sharedHelper.stopBackgroundMusic() : MusicHelper.sharedHelper.playBackgroundMusic()
        }
    }
    let transitionEffect = AnyTransition.slide.combined(with: .opacity)
    
    var backgrid = BackGridModel()
    
    var body: some View {
        ZStack {
        
            VStack {
                Spacer().frame(height:27)
                HStack {
                    Spacer()
                    Button(action:{
                        muteBGM.toggle()
                    }) {
                        Text(muteBGM ? "BGM off" : "BGM on")
                    }
                    Button(action: {
                        self.showRecord = true
                    }) {
                        Text("Show Record")
                    }
                    Spacer().frame(width:20)
                }
                Spacer().frame(height:40)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Score:\(self.chessboard.score)").font(Font.custom("Eraser Dust", size: 60)).foregroundColor(.white)
                    HStack{
                        Text("Level:").font(Font.custom("Eraser Dust",size: 24)).opacity(0.95).foregroundColor(.white)
                        Image("level_bg").overlay(
                            Text("\(self.chessboard.level)")
                            .font(Font.custom("Eraser Dust",size: 24))
                                .opacity(0.95)
                                .foregroundColor(.white)
                            .fixedSize()
                        )
                    }
                    
                }
               
               ZStack(alignment: .center) {
                   BackGrid(columnTap: { column in
                       self.newBallOffsetX = CGFloat((column - 3)) * ballEdge
                       self.lastNewBallOffsetX = self.newBallOffsetX
                       self.dropBall(column)
                   }).environmentObject(backgrid)
                       .frame(width:ballEdge * 7, height: ballEdge * 7)
                   .disabled(self.chessboard.operating)
                    .padding(35)
                  
                HStack(spacing:0) {
                    ForEach (0..<self.chessboard.columns, id: \.self) { column in
                        Ball().environmentObject(self.chessboard.outRangeBalls[column])
                           .allowsHitTesting(false)
                      }
                }.offset(y:newBallDefaultY + ballEdge)
                
                   VStack(spacing:0) {
                    ForEach (0..<self.chessboard.rows, id: \.self) { row in
                               HStack(spacing:0) {
                               ForEach (0..<self.chessboard.columns, id: \.self) { column in
                                   Ball().environmentObject(self.chessboard[row, column])
                                    .allowsHitTesting(false)
                               }
                           }.allowsHitTesting(false)
                       }
                   }.allowsHitTesting(false)
                       .animation(.spring())
                   Ball().environmentObject(self.chessboard.newBall).offset(x: self.newBallOffsetX ,y: self.newBallOffsetY)
                
            if self.chessboard.scoreTime != 1 {
                Text("Chain X \(self.chessboard.scoreTime)")
                    .font(Font.custom("Eraser Dust",size: 24 + 0.2 * CGFloat(self.chessboard.scoreTime)))
                    .fixedSize()
                    .frame(width:300)
                    .opacity(0.95)
                    .transition(transitionEffect)
                    .foregroundColor(.yellow)
                    .offset(y:newBallDefaultY - 50)
                    .animation(.easeInOut)
            }
                
               }.padding(.top, 100)
                
               Spacer()
               
                HStack(spacing: -20) {
                    ForEach(self.chessboard.chalkStack.chalks.reversed(), id: \.id) {chalk in
                        ChalkView().environmentObject(chalk).rotationEffect(.degrees(180))
                   }
                }.rotationEffect(.degrees(180))
                .padding(.bottom, 16)
                    .offset(x: -40)
                

           }
                .contentShape(Rectangle()) // gesture zone
           .highPriorityGesture(DragGesture().onChanged{ gesture in
                   let moveX = gesture.translation.width * 1.5 + self.lastNewBallOffsetX
                   if abs(moveX) <= 3 * ballEdge {
                       self.moveNewBall(moveX)
                   }
               }
               .onEnded{ _ in
                   self.moveNewBall(self.newBallOffsetX)
                   self.lastNewBallOffsetX = self.newBallOffsetX
           })
               .alert(isPresented: .init(get: {self.chessboard.gameOver}, set: {self.chessboard.gameOver = $0 })) {
                   Alert(title: Text("Game Over"), message: Text("Try again?"), dismissButton: .default(Text("Yes"), action: {
                       withAnimation(.easeInOut) {
                        RecordList.shared.createNewRecord(score: self.chessboard.score, level: self.chessboard.level)
                           self.chessboard.createChessBoard()
                       }
                   }))
            }
            .background(Image("chalkball_bg").resizable().disabled(true))
            if showRecord {
                RecordView(closeAction: {
                    self.showRecord = false
                })
                    .background(Color.gray)
                    .environmentObject(RecordList.shared).transition(AnyTransition.slide.combined(with: .opacity))
                    .animation(.spring())
            }
        }.onAppear{
            MusicHelper.sharedHelper.playBackgroundMusic()
        }
    }
    
    func moveNewBall(_ offsetX:CGFloat) {
        withAnimation(.easeOut) {
            let benchmarkX = self.chessboard.benchmarkX(offsetX: offsetX)
            self.newBallOffsetX = benchmarkX.newX
            self.backgrid.currentColumn = benchmarkX.column
            
        }
        
    }
    
    func dropBall(_ column:Int) {
        let offsetY = self.chessboard.dropNewBall(column)
        withAnimation(Animation.linear(duration: dropDuration)) {
            self.newBallOffsetY = newBallDefaultY + offsetY
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.newBallOffsetY = newBallDefaultY
            self.newBallOffsetX = 0.0
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChalkSevenView().environmentObject(Chessboard())
    }
}
