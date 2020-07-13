//
//  ContentView.swift
//  FireBase SwiftUI
//
//  Created by Mahbubur Rahman Mishal on 6/7/20.
//  Copyright © 2020 Mahbubur Rahman Mishal. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    @State var show = false
    @State var status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
    var body: some View {
        NavigationView {
            VStack{
                if self.status{
                    Homescreen()
                } else {
                    ZStack {
                        NavigationLink(destination: SignUp(show: self.$show), isActive: self.$show) {
                            Text("")
                        }.hidden()
                        
                        Login(show: self.$show )
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("status"),  object: nil, queue: .main) { (_) in
                    self.status = UserDefaults.standard.value(forKey: "status") as? Bool ?? false
                }
            }
        }
    }
    
    struct Homescreen : View {
        var body: some View {
            VStack {
                Text("Logged Succesfully")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black.opacity(0.7))
                
                Button(action: {
                    try! Auth.auth().signOut()
                    UserDefaults.standard.set(false, forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                    }){
                        Text("Sign In")
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width  - 50)
                    }
                .background(Color("AppRed"))
                .cornerRadius(10)
                    .padding(.top, 25)
            }
        }
    }
}

struct Login: View {
    @State var color   = Color.red.opacity(0.7)
    @State var email   = ""
    @State var pass    = ""
    @State var visible = false
    @State var alert   = false
    @State var error   = ""
    @Binding var show:Bool
    var body : some View {
        ZStack {
            ZStack(alignment: .topTrailing) {
               GeometryReader{_ in
                   VStack {
                       Image("logo")
                           .resizable()
                           .frame(width: 120.0, height: 180.0)

                       Text("Log in to your account")
                           .font(.title)
                           .fontWeight(.bold)
                           .padding(.top, 35)

                       TextField("Email", text: self.$email)
                       .autocapitalization(.none)
                       .padding()
                       .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color("AppRed") : self.color, lineWidth: 2))
                       .padding(.top, 25)
                       
                       HStack(spacing: 15) {
                           VStack {
                               if self.visible {
                                   TextField("Password", text: self.$pass)
                                   .autocapitalization(.none)
                               } else {
                                   SecureField("Password", text: self.$pass)
                                   .autocapitalization(.none)
                               }
                           }
                           Button(action: {
                               self.visible.toggle()
                           }) {
                               Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                               .foregroundColor(self.color)
                           }
                       }
                       .padding()
                       .background(RoundedRectangle(cornerRadius: 4).stroke(self.pass != "" ? Color("AppRed") : self.color, lineWidth: 2))
                       .padding(.top, 25)
                       
                       HStack(spacing: 15) {
                           Spacer()
                           Button(action: {
                            self.reset()
                           }) {
                              Text("Forget Password")
                               .fontWeight(.bold)
                               .foregroundColor(Color("AppRed"))
                           }
                       }
                       .padding(.top, 25)
                       
                       Button(action: {
                        self.verify()
                       }){
                           Text("Sign In")
                               .foregroundColor(.white)
                               .padding(.vertical)
                               .frame(width: UIScreen.main.bounds.width  - 50)
                       }
                   .background(Color("AppRed"))
                   .cornerRadius(10)
                       .padding(.top, 25)
                   }
                   .padding(.horizontal, 25)
               }
                   
                   Button(action: {
                       self.show.toggle()
                   }) {
                       Text("Register")
                           .fontWeight(.bold)
                           .foregroundColor(Color("AppRed"))
                   }.padding()
               }
            
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
    }
    
    func verify() {
        if self.email != "" && self.pass != "" {
            Auth.auth().signIn(withEmail: self.email, password:  self.pass) {
                (res, err) in
                
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                }
                
                print("success")
                UserDefaults.standard.set(true, forKey: "status")
                NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
            }
        } else {
            self.error = "Please fill all the contents properly"
            self.alert.toggle()
        }
    }
    
    func reset() {
        if self.email != "" {
            Auth.auth().sendPasswordReset(withEmail: self.email) { (err) in
                if err != nil {
                    self.error = err!.localizedDescription
                    self.alert.toggle()
                    return
                } else {
                    self.error = "RESET"
                    self.alert.toggle()
                }
            }
        } else {
            self.error = "Email Id is empty"
            self.alert.toggle()
        }
    }
}

struct SignUp: View {
    @State var color     = Color.red.opacity(0.7)
    @State var email     = ""
    @State var pass      = ""
    @State var repass    = ""
    @State var visible   = false
    @State var revisible = false
    @State var alert   = false
    @State var error   = ""
    @Binding var show:Bool

    var body : some View {
        ZStack {
            ZStack(alignment: .topLeading) {
                       GeometryReader{_ in
                           VStack {
                               Image("logo")
                                   .resizable()
                                   .frame(width: 120.0, height: 180.0)

                               Text("Sign Up a new account")
                                   .font(.title)
                                   .fontWeight(.bold)
                                   .padding(.top, 35)

                               TextField("Email", text: self.$email)
                               .autocapitalization(.none)
                               .padding()
                               .background(RoundedRectangle(cornerRadius: 4).stroke(self.email != "" ? Color("AppRed") : self.color, lineWidth: 2))
                               .padding(.top, 25)
                               
                               HStack(spacing: 15) {
                                   VStack {
                                       if self.visible {
                                           TextField("Password", text: self.$pass)
                                           .autocapitalization(.none)
                                       } else {
                                           SecureField("Password", text: self.$pass)
                                           .autocapitalization(.none)
                                       }
                                   }
                                   Button(action: {
                                       self.visible.toggle()
                                   }) {
                                       Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                                       .foregroundColor(self.color)
                                   }
                               }
                               .padding()
                               .background(RoundedRectangle(cornerRadius: 4).stroke(self.pass != "" ? Color("AppRed") : self.color, lineWidth: 2))
                               .padding(.top, 25)
                               
                               HStack(spacing: 15) {
                                   VStack {
                                       if self.revisible {
                                           TextField("Re-enter", text: self.$repass)
                                            .autocapitalization(.none)
                                       } else {
                                           SecureField("Re-enter", text: self.$repass)
                                            .autocapitalization(.none)
                                       }
                                   }
                                   Button(action: {
                                       self.revisible.toggle()
                                   }) {
                                       Image(systemName: self.revisible ? "eye.slash.fill" : "eye.fill")
                                       .foregroundColor(self.color)
                                   }
                               }
                               .padding()
                               .background(RoundedRectangle(cornerRadius: 4).stroke(self.repass != "" ? Color("AppRed") : self.color, lineWidth: 2))
                               .padding(.top, 25)
                               
                               Button(action: {
                                self.register()
                               }){
                                   Text("Sign Up")
                                       .foregroundColor(.white)
                                       .padding(.vertical)
                                       .frame(width: UIScreen.main.bounds.width  - 50)
                               }
                               .background(Color("AppRed"))
                               .cornerRadius(10)
                               .padding(.top, 25)
                           }
                           .padding(.horizontal, 25)
                       }
                       
                       Button(action: {
                           self.show.toggle()
                       }) {
                           Image(systemName: "chevron.left")
                               .font(.title)
                               .foregroundColor(Color("AppRed"))
                       }.padding()
                   }
            
            if self.alert {
                ErrorView(alert: self.$alert, error: self.$error)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    func register() {
        if self.email != "" {
            if self.pass == self.repass {
                Auth.auth().createUser(withEmail: self.email, password: self.pass) {
                    (res, err) in
                    
                    if err != nil {
                        self.error = err!.localizedDescription
                        self.alert.toggle()
                        return
                    }
                    print("Success")
                    UserDefaults.standard.set(true, forKey: "status")
                    NotificationCenter.default.post(name: NSNotification.Name("status"), object: nil)
                }
            } else {
                self.error = "Password Mismatch"
                self.alert.toggle()
            }
        } else {
            self.error = "Please fill up all the contents properly"
            self.alert.toggle()
        }
    }
}

struct ErrorView : View {
    @State var color = Color.black.opacity(0.7)
    @Binding var alert : Bool
    @Binding var error : String
    var body: some View {
        GeometryReader {_ in
            VStack {
                //Message or Error
                HStack {
                    Text(self.error == "RESET" ? "Message" : "Error")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(self.color)
                    Spacer()
                }
                .padding(.horizontal, 25)
                
                //Password Link has been senf or Error message
                Text(self.error == "RESET" ? "Password Link has been sent" : self.error)
                    .foregroundColor(self.color)
                    .padding(.top)
                    .padding(.horizontal, 25)
                
                //Button (OK or Cancel)
                Button(action: {
                    self.alert.toggle()
                }) {
                    //Button Text
                    Text(self.error == "RESET" ? "OK" : "Cancel")
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 120)
                }
                .background(Color("AppRed"))
                .cornerRadius(10)
                .padding(.top, 25)
            }
            .padding(.vertical, 25)
            .frame(width: UIScreen.main.bounds.width - 70)
            .background(Color.white)
            .cornerRadius(15)
        }
        .background(Color.black.opacity(0.35).edgesIgnoringSafeArea(.all))
    }
}

