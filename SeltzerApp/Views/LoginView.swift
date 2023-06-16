//
//  LoginView.swift
//  SeltzerApp
//
//  Created by Mitch Watson on 6/9/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
@EnvironmentObject var model: UserModel
    @State private var email = ""
    @State private var password = ""
    @State var selectedTab = 0
    
    var body: some View {
        VStack{
            if model.currentUser == nil{
                TabView(selection: $selectedTab) {
                    
                    VStack {
                        Text("Login")
                            .font(.title)
                            .padding()
                        Image("SeltzerAppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 240)
                            .padding()
                        
                        ZStack{
                            Rectangle()
                                .frame(width: 350, height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            TextField("Email", text: $email)
                                .foregroundColor(.white)
                                .textFieldStyle(.plain)
                                .padding(.leading, 40)
                                .overlay(
                                    Text("Email")
                                        .foregroundColor(.white) // Set the placeholder text color to white
                                        .opacity(email.isEmpty ? 0.6 : 0)
                                )
                        }

                        ZStack{
                            Rectangle()
                                .frame(width: 350, height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            SecureField("Password", text: $password)
                                .foregroundColor(.white)
                                .textFieldStyle(.plain)
                                .padding(.leading, 40)
                                .overlay(
                                    Text("Password")
                                        .foregroundColor(.white) // Set the placeholder text color to white
                                        .opacity(password.isEmpty ? 0.6 : 0)
                                )
                            
                        }

                        Button {
                            model.login(email: email, password: password)
                        } label: {
                            ZStack{
                                Rectangle()
                                    .frame(width: 350, height: 50, alignment: .center)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                Text("Submit")
                                    .foregroundColor(.gray)
                            }
                            
                            
                        }
                        .padding(.top, 3)
                        Button {
                            selectedTab = 1
                        } label: {
                            ZStack{
                                Text("Don't have an account? Swipe to sign up ->")
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.vertical, 50)
                        
                    }
                    .tag(0)
                    VStack {
                        Text("Sign Up")
                            .font(.title)
                            .padding()
                        Image("SeltzerAppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 240)
                            .padding()
                        
                        ZStack{
                            Rectangle()
                                .frame(width: 350, height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            TextField("Email", text: $email)
                                .foregroundColor(.white)
                                .textFieldStyle(.plain)
                                .padding(.leading, 40)
                                .overlay(
                                    Text("Email")
                                        .foregroundColor(.white) // Set the placeholder text color to white
                                        .opacity(email.isEmpty ? 0.6 : 0)
                                )
                        }

                        ZStack{
                            Rectangle()
                                .frame(width: 350, height: 50, alignment: .center)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            SecureField("Password", text: $password)
                                .foregroundColor(.white)
                                .textFieldStyle(.plain)
                                .padding(.leading, 40)
                                .overlay(
                                    Text("Password")
                                        .foregroundColor(.white) // Set the placeholder text color to white
                                        .opacity(password.isEmpty ? 0.6 : 0)
                                )
                            
                        }

                        Button {
                            model.register(email: email, password: password)
                            selectedTab = 2
                        } label: {
                            ZStack{
                                Rectangle()
                                    .frame(width: 350, height: 50, alignment: .center)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                Text("Sign Up")
                                    .foregroundColor(.gray)
                            }
                    
                        }
                        .padding(.bottom, 130)

                    }
                    .tag(1)

                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            else{
                RatingView()
            }
        }

    }

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserModel())
    }
}
