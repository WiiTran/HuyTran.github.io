//
//  SelectRegistrationView.swift
//  Appause
//
//  Created by Huy Tran on 4/16/24.
//  Modified by Dakshina EW on 10/28/2024.
//

import SwiftUI
import KeychainSwift
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct SelectRegistrationView: View
{
    @Binding var showNextView: DisplayState
    @State private var registerError: String = " "
    
    @State private var studentFirstName: String = ""
    @State private var studentLastName: String = ""
    @State private var studentEmail: String = ""
    @State private var studentPassword: String = ""
    @State private var studentPassConfirm: String = ""
    
    @State private var teacherFirstName: String = ""
    @State private var teacherLastName: String = ""
    @State private var teacherEmail: String = ""
    @State private var teacherPassword: String = ""
    @State private var teacherPassConfirm: String = ""
    
    
    @State private var confirmStatus: String = ""
    @State private var passwordStatus: String = ""
    
    @State private var showTeacherRegistrationFields = false
    @State private var showStudentRegistrationFields = false
    
    @State var buttonColorBottom = Color.black
    @State var buttonColorTop = Color.black
    
    let keychain = KeychainSwift()
    
    //helper variables - written by Luke Simoni
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    @State var userInfo = AuthDataResult()
    @State var tempString: [String] = []
    @State var studentID: String = ""
    
    // helper String specifically for matching 'student' portion
    // of student email
    @State var tempStudentString: String = ""
    
    // helper String specifically for matching 'sanjuan.edu' portion
    // of student and teacher emails
    @State var tempSanJuanString: String = ""
    
    struct TextFieldWithEyeIcon: View {
        // Placeholder text for the text field
        var placeholder: String
        
        // Binding to a text property, so changes to this text will be reflected externally
        @Binding var text: String
        
        // A flag indicating whether this text field should display as a secure (password) field
        var isSecure: Bool
        
        // Binding to the visibility state of the password (visible or hidden)
        @Binding var visibility: String
        
        var body: some View {
            HStack {
                if isSecure {
                    // SecureField is used for password input
                    SecureField(placeholder, text: $text)
                } else {
                    // TextField is used for non-password input
                    TextField(placeholder, text: $text)
                }
                
                // Button for toggling password visibility
                Button(action: {
                    // Toggle visibility state between "visible" and "hidden"
                    visibility = isSecure ? "visible" : "hidden"
                }) {
                    // Show the "eye" icon for password visibility, or "eye.slash" for hidden
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .foregroundColor(Color.black)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .frame(width: 370)
            .disableAutocorrection(true)
            .autocapitalization(.none)
        }
    }
    
    
    var body: some View {
        VStack{
            Text("Are you a teacher or a student?")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .padding([.top, .bottom], 15)
            
            Text(registerError)
                .fontWeight(.bold)
                .foregroundColor(.red)
                .padding(.bottom, 20)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)

            
            HStack
            {
                Button(action:
                        {
//                    let registeredUsername = keychain.get("teacherUserKey")
//                    let registeredPassword = keychain.get("teacherPassKey")
//                    
                    withAnimation
                    {
                        showTeacherRegistrationFields.toggle()
                        showStudentRegistrationFields = false
                        updateButtonColors()
                    }
                    
                })
                {
                    VStack
                    {
                        Text("Teacher")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 150, height: 20, alignment: .center)
                        Image(systemName: "graduationcap")
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(buttonColorTop)
                .cornerRadius(10)
                
                Button(action:
                        {
//                    let registeredUsername = keychain.get("studentUserKey")
//                    let registeredPassword = keychain.get("studentPassKey")
//                    
                    withAnimation
                    {
                        //showNextView = .login
                        showStudentRegistrationFields.toggle()
                        showTeacherRegistrationFields = false
                        updateButtonColors()                    }
                })
                {
                    VStack{
                        Text("Student")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 150, height: 16, alignment: .center)
                        Image(systemName: "studentdesk")
                            .padding(4)
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(buttonColorBottom)
                .cornerRadius(10)
            }
//            .padding(.bottom, 100)
            
            if showTeacherRegistrationFields
            {
                VStack
                {
                    TextField(
                        "First Name",
                        text: $teacherFirstName
                    )
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(width: 370)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    
                    TextField(
                        "Last Name",
                        text: $teacherLastName
                    )
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(width: 370)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    
                    TextField(
                        "Email",
                        text: $teacherEmail
                    )
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(width: 370)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    
                    if passwordStatus == "visible"
                    {
                        TextFieldWithEyeIcon(placeholder: "Password", text: $teacherPassword, isSecure: false, visibility: $passwordStatus)
                    }
                    else
                    {
                        TextFieldWithEyeIcon(placeholder: "Password", text: $teacherPassword, isSecure: true, visibility: $passwordStatus)
                    }
                    
                    if(confirmStatus=="visible")
                    {
                        TextFieldWithEyeIcon(placeholder: "Confirm Password", text: $teacherPassConfirm, isSecure: false, visibility: $confirmStatus)
                    }
                    else
                    {
                        TextFieldWithEyeIcon(placeholder: "Confirm Password", text: $teacherPassConfirm, isSecure: true, visibility: $confirmStatus)
                    }
                    Button(action:
                            {
                        tempString = teacherEmail.components(separatedBy: ".")
                        
                        if(tempString.count > 1 && !tempString[1].isEmpty) {
                            tempString = tempString[1].components(separatedBy: "@")
                        } else {
                            tempString = []
                        }
                        
                        tempSanJuanString = (tempString.count > 1 && !tempString[1].isEmpty) ? tempString[1] : ""
                        
                        //test strings
                        print(tempSanJuanString)
                        
                        if (teacherFirstName == "" || teacherLastName == "" || teacherEmail == "" || teacherPassword == "" || teacherPassConfirm == "")
                        {
                            registerError = "Please fill in all of the fields."
                        }
                        else if !(tempSanJuanString == "sanjuan"){
                            registerError = "Format of the email submitted is incorrect."
                        }
                        else if (validateEmail(teacherEmail) == false)
                        {
                            registerError = "Please enter a valid email address."
                        }
                        else if (validatePassword(teacherPassword) == false)
                        {
                            registerError = "Password Requires:\nAt least 12 characters, a number, an uppercase letter, and a special character."
                        }
                        else if (teacherPassword != teacherPassConfirm){
                            registerError = "Passwords do not match. Try again."
                        }
                        else
                        {
                            registerError = ""
                            
                            keychain.set(teacherEmail.lowercased(), forKey: "teacherUserKey")
                            keychain.set(teacherPassword, forKey: "teacherPassKey")
                            keychain.set(teacherFirstName, forKey: "teacherFirstNameKey")
                            keychain.set(teacherLastName, forKey: "teacherLastNameKey")
                            
                            // Generate a unique teacher ID and proceed with registration
                            generateUniqueTeacherID { uniqueID in
                                guard let teacherID = uniqueID else {
                                    registerError = "Error generating Teacher ID. Please try again."
                                    return
                                }
                                
                                Task {
                                    do {
                                        userInfo = try await AuthManager.sharedAuth.createUser(
                                            email: teacherEmail,
                                            password: teacherPassword,
                                            fname: teacherFirstName,
                                            lname: teacherLastName
                                        )
                                        
                                        print(userInfo.email! + userInfo.fname! + userInfo.lname!)
                                        
                                        guard let email = userInfo.email,
                                              let fname = userInfo.fname,
                                              let lname = userInfo.lname,
                                              !email.isEmpty, !fname.isEmpty, !lname.isEmpty else {
                                            return
                                        }
                                        
                                        do {
                                            let ref = try await db.collection("Teachers").addDocument(data: [
                                                "Name": "\(fname) \(lname)",
                                                "Email": email,
                                                "teacherID": teacherID,
                                                "Date Created": Timestamp(date: Date())
                                            ])
                                            
                                            _ = try await db.collection("Teachers")
                                                .document(ref.documentID)
                                                .collection("ClassesTaught")
                                                .addDocument(data: [
                                                    "Placeholder": "."
                                                ])
                                            
                                            print("Document added with ID: \(ref.documentID)")
                                            
                                            withAnimation {
                                                showNextView = .login
                                            }
                                            
                                        } catch let dbError {
                                            print("Error adding document: \(dbError.localizedDescription)")
                                        }
                                        
                                    } catch let createUserError {
                                        registerError = "Registration of user failed. \(createUserError.localizedDescription)"
                                        print("error creating user")
                                    }
                                }
                            }
                        }
                    })
                    {
                        Text("Register")
                            .padding()
                            .frame(width: 370)
                            .fontWeight(.bold)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.bottom, 25)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Already have an account?")
                        //.padding(.leading, 15)
                        
                        Button(action: {
                            withAnimation {
                                showNextView = .login
                            }
                        }) {
                            Text("Sign in here!")
                                .foregroundColor(.blue)
                                .padding(.leading, -4.0)
                        }
                        Spacer()
                    }
                }
            }
            
            if showStudentRegistrationFields
            {
                VStack
                {
                    TextField("First Name", text: $studentFirstName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .frame(width: 370)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    TextField("Last Name", text: $studentLastName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .frame(width: 370)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    TextField("Email", text: $studentEmail)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .frame(width: 370)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    if passwordStatus == "visible"
                    {
                        TextFieldWithEyeIcon(placeholder: "Password", text: $studentPassword, isSecure: false, visibility: $passwordStatus)
                    }
                    else
                    {
                        TextFieldWithEyeIcon(placeholder: "Password", text: $studentPassword, isSecure: true, visibility: $passwordStatus)
                    }
                    
                    if(confirmStatus=="visible")
                    {
                        TextFieldWithEyeIcon(placeholder: "Confirm Password", text: $studentPassConfirm, isSecure: false, visibility: $confirmStatus)
                    }
                    else
                    {
                        TextFieldWithEyeIcon(placeholder: "Confirm Password", text: $studentPassConfirm, isSecure: true, visibility: $confirmStatus)
                    }
                    
                    Button(action: {
                        
                        tempString = studentEmail.components(separatedBy: "@")
                        
                        studentID = (tempString.count > 0  && !tempString[0].isEmpty) ? tempString[0] : ""
                        
                        if (tempString.count > 1 && !tempString[1].isEmpty) {
                            tempString = tempString[1].components(separatedBy: ".")
                        } else {
                            tempString = []
                        }
                        
                        tempStudentString = (tempString.count > 0 && !tempString[0].isEmpty) ? tempString[0] : ""
                        tempSanJuanString = (tempString.count > 1 && !tempString[1].isEmpty) ? tempString[1] : ""
                        
                        //test strings
                        print(studentID + " " + tempStudentString + " " + tempSanJuanString)
                        
                        if (studentFirstName == "" || studentLastName == "" || studentEmail == "" || studentPassword == "" || studentPassConfirm == ""){
                            registerError = "Please fill in all of the fields."
                        }
                        else if !(tempStudentString == "student") {
                            registerError = "Format of the email submitted is incorrect."
                        }
                        else if !(tempSanJuanString == "sanjuan"){
                            registerError = "Format of the email submitted is incorrect."
                        }
                        else if !validateStudentID(studentID) {
                            registerError = "Please use the student ID number as the first component of the account's email address."
                        }
                        else if (validateEmail(studentEmail) == false){
                            registerError = "Please enter a valid email address."
                        }
                        else if (validatePassword(studentPassword) == false){
                            registerError = "Password Requires:\nAt least 12 characters, a number, an uppercase letter, and a special character."
                        }
                        else if (studentPassword != studentPassConfirm){
                            registerError = "Passwords do not match. Try again."
                        }
                        else{
                            registerError = " " //resets the error message if there is one
                            
                            //adds information into the keychain
                            keychain.set(studentEmail.lowercased(), forKey: "studentUserKey")
                            keychain.set(studentPassword, forKey: "studentPassKey")
                            keychain.set(studentFirstName, forKey: "studentFirstNameKey")
                            keychain.set(studentLastName, forKey: "studentLastNameKey")
                            
                            Task {
                                do {
                                    userInfo = try await AuthManager.sharedAuth.createUser(
                                        email: studentEmail,
                                            password: studentPassword,
                                            fname: studentFirstName,
                                            lname: studentLastName)
                                    print(userInfo.email! + userInfo.fname! + userInfo.lname!)
                                    
                                    guard let email = userInfo.email,
                                          let fname = userInfo.fname,
                                          let lname = userInfo.lname,
                                          !email.isEmpty,
                                          !fname.isEmpty,
                                          !lname.isEmpty
                                    else {
                                        return
                                    }
                                    
                                    do {
                                        let ref = try await db.collection("Users").addDocument(data: [
                                            "Name": userInfo.fname! + " " + userInfo.lname!,
                                            "StudentId": studentID,
                                            "Email": userInfo.email!,
                                            "Date Created": Timestamp(date: Date())
                                        ])
                                        
                                        print("Document added with ID: \(ref.documentID)")
                                        
                                        withAnimation {
                                            //show nextView .whateverViewYouWantToShow defined in ContentView Enum
                                            showNextView = .login
                                        }
                                        
                                    } catch let dbError{
                                        print("Error adding document: \(dbError.localizedDescription)")
                                    }
                                    
                                } catch let createUserError {
                                    registerError = "Registration of user failed.  \(createUserError.localizedDescription)"
                                }
                            }
                        }
                    }){
                        Text("Register")
                            .padding()
                            .frame(width: 370)
                            .fontWeight(.bold)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        //.padding(.leading, 200)
                            .padding(.bottom, 25)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Already have an account?")
                            //.padding(.leading, 15)
                        
                        Button(action: {
                            withAnimation {
                                showNextView = .login
                            }
                        }) {
                            Text("Sign in here!")
                                .foregroundColor(.blue)
                                .padding(.leading, -4.0)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    // Helper function to generate and ensure a unique 6-digit teacher ID
    private func generateUniqueTeacherID(completion: @escaping (String?) -> Void) {
        let newTeacherID = String(format: "%06d", Int.random(in: 0...999999))

        checkIfTeacherIDExists(teacherID: newTeacherID) { exists in
            if exists {
                generateUniqueTeacherID(completion: completion)
            } else {
                completion(newTeacherID)
            }
        }
    }

    // Helper function to check if the teacher ID exists in Firestore
    private func checkIfTeacherIDExists(teacherID: String, completion: @escaping (Bool) -> Void) {
        db.collection("Teachers")
            .whereField("teacherID", isEqualTo: teacherID)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error checking Teacher ID: \(error.localizedDescription)")
                    completion(true)  // Assume it exists
                    return
                }
                let exists = !(querySnapshot?.documents.isEmpty ?? true)
                completion(exists)
            }
    }
    
    // Function to update button colors based on selection
    private func updateButtonColors() {
        if showTeacherRegistrationFields && !showStudentRegistrationFields {
            buttonColorTop = .black
            buttonColorBottom = .gray
        } else if !showTeacherRegistrationFields && showStudentRegistrationFields {
            buttonColorTop = .gray
            buttonColorBottom = .black
        } else {
            buttonColorTop = .black
            buttonColorBottom = .black
        }
    }

    func validateEmail(_ email: String) -> Bool
    {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", options: [.caseInsensitive])
        return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.utf16.count)) != nil
    }
    
    func validatePassword(_ password: String) -> Bool
    {
        let regexNumber = ".*[0-9]+.*"
        let regexUpperCase = ".*[A-Z]+.*"
        let regexSpecialCharacter = ".*[!\"#$%&'()*+,-./:;<=>?@[\\\\]^_`{|}~].*"
        let regexWhiteSpace = ".*\\s.*"
        
        let checkNumber = NSPredicate(format: "SELF MATCHES %@", regexNumber)
        let checkUpper = NSPredicate(format: "SELF MATCHES %@", regexUpperCase)
        let checkSpecial = NSPredicate(format: "SELF MATCHES %@", regexSpecialCharacter)
        let checkWhite = NSPredicate(format: "SELF MATCHES %@", regexWhiteSpace)
        
        let lengthFlag = password.count >= 12
        let numberFlag = checkNumber.evaluate(with: password)
        let upperFlag = checkUpper.evaluate(with: password)
        let specialFlag = checkSpecial.evaluate(with: password)
        // note - this flag is using the not operator in order to ensure passwords
        //        do not contain whitespaces.
        let whitespaceFlag = !checkWhite.evaluate(with: password)
        
        return lengthFlag && numberFlag && upperFlag && specialFlag && whitespaceFlag
    }
    
    //helper function for validating student ID numbers - written by Luke Simoni
    func validateStudentID(_ studentID: String ) -> Bool {
        let digitsOnlyPattern = "^[0-9]{6}$"
        
        do {
            let regex = try NSRegularExpression(pattern: digitsOnlyPattern)
            let range = NSRange(location: 0, length: studentID.utf16.count)
            return regex.firstMatch(in: studentID, options: [], range: range) != nil
        } catch {
            return false
        }
    }
}



struct SelectRegistrationView_Previews: PreviewProvider
{
    @State static private var showNextView: DisplayState = .selectRegistration
    
    static var previews: some View
    {
        SelectRegistrationView(showNextView: $showNextView)
    }
}
