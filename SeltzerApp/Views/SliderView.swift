//
//  SliderView.swift
//  SeltzerApp
//
//  Created by Mitch Watson on 6/10/23.
//

import SwiftUI

struct SliderView: View {
    @EnvironmentObject var model: UserModel
    @State var seltzerBrand: String
    @State var seltzerFlavor: String
    @State var value: Double
    @State var index: Int
    
    var userScoreBinding: Binding<Double> {
        Binding<Double>(
            get: {
                model.currentUser?.seltzers[index].userScore ?? 0.0
            },
            set: { newValue in
                model.currentUser?.seltzers[index].userScore = newValue
            }
        )
    }
    
    var body: some View {
        ZStack{
            Rectangle()
                .cornerRadius(6)
                .shadow(radius: 3)
                .foregroundColor(.white)
                .frame(width: 360, height: 90, alignment: .center)
            VStack(spacing: 0){
                HStack{
                    Text(seltzerBrand)
                    Text(seltzerFlavor)
                    Text(String(format: "%.1f", model.currentUser?.seltzers[index].userScore ?? 0.0))
                }
                Slider(value: userScoreBinding, in: 0...10, step: 0.1)
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                Button {
                    model.currentUser?.seltzers[index].isUpdatingScore = false
                    model.currentUser?.seltzers[index].scored = true
                    model.updateSeltzerData()
                } label: {
                    Text("Submit")
                }
                
            }
        }
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        SliderView(seltzerBrand: "test", seltzerFlavor: "test", value: 0.0, index: 0)
            .environmentObject(UserModel())
    }
}

