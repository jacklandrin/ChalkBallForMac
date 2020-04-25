//
//  RecordView.swift
//  ChalkSeven
//
//  Created by jack on 2020/4/13.
//  Copyright © 2020 jack. All rights reserved.
//

import SwiftUI


struct RecordView: View {
    @EnvironmentObject var recordList: RecordList
    var closeAction:() -> Void
    
    var body: some View {
        VStack (alignment:.trailing) {
            Button(action: closeAction) {
                Text("Close")
            }
            List{
               ForEach (recordList.records.indices) { index in
                   HStack {
                       Image("chalk").foregroundColor(self.recordList.championIndex == index ? .red : nil)
                       Text("\(self.recordList.records[index].score)")
                       Text("(\(self.recordList.records[index].level))").opacity(0.90)
                       Spacer()
                       Text(self.recordList.records[index].date)
                   }
               }
           }
        }
       
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(closeAction: {}).environmentObject(RecordList.shared)
    }
}
