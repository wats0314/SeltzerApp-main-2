//
//  ContentView.swift
//  SeltzerApp
//
//  Created by Mitch Watson on 6/9/23.
//

import SwiftUI

struct RatingView: View {
    
    @EnvironmentObject var user: UserModel
    @State private var score: Double = 5.0
    
    var body: some View {
        VStack {
            NavigationStack {
                ScrollView {
                    if let currentUser = user.currentUser {
                        ForEach(currentUser.seltzers.indices, id: \.self) { index in
                            VStack {
                                if currentUser.seltzers[index].isUpdatingScore == true {
                                    SliderView(seltzerBrand: currentUser.seltzers[index].brand, seltzerFlavor: currentUser.seltzers[index].flavor, value: currentUser.seltzers[index].userScore!, index: index)
                                } else {
                                    ZStack {
                                        Rectangle()
                                            .cornerRadius(10)
                                            .shadow(radius: 3)
                                            .foregroundColor(.white)
                                            .frame(width: 360, height: 90, alignment: .center)
                                        HStack {
                                            Image(currentUser.seltzers[index].image!)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 70, height: 80, alignment: .center)
                                                .padding(.leading, 30)
                                            Spacer()
                                            VStack(spacing: 2) {
                                                Text(currentUser.seltzers[index].brand)
                                                Text(currentUser.seltzers[index].flavor)
                                            }
                                            .font(.title2)
                                            Spacer()
                                            Button {
                                                user.currentUser?.seltzers[index].isUpdatingScore = true
                                            } label: {
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 70, height: 70, alignment: .center)
                                                        .foregroundColor(user.currentUser!.seltzers[index].scored ? .blue : .red)
                                                    Text(String(format: "%.1f", currentUser.seltzers[index].userScore!))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            
            Button {
                user.signOut()
            } label: {
                Text("Sign Out")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let user = SeltzerAppUser(id: "0", name: "Mitch", seltzers: [
            Seltzer(id:"test", brand: "White Claw", flavor: "Natural Lime", image: "WhiteClawNaturalLime", userScore: 0.0, globalScore: 0.0, scored: false)
        ])
        
        let userModel = UserModel()
        userModel.currentUser = user
        
        return RatingView()
            .environmentObject(userModel)
    }
}
