import SwiftUI
import Firebase

struct ContentView: View {
    @State private var showSplash = true
    @State private var showLogin = false

    var body: some View {
        ZStack {
            if showSplash {
                // Vista del splash
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                                showLogin = true
                            }
                        }
                    }
            } else if showLogin {
                // Vista de inicio de sesión
                LoginView()
            } else {
                // Vista principal
                VStack {
                    Text("¡Hola, mundo!")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)

                    Button(action: {
                        // Acción del botón
                    }) {
                        Text("Presionar")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SplashView: View {
    var body: some View {
        VStack {
            Image("Logotipo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
        }
    }
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoginValid = true
    @State private var loginWarning = ""
    @State private var isFieldEmpty = false
    @State private var isUserLoggedIn = false //Se agrega la variable para podernos mover
    
    var body: some View {
        NavigationView {
            VStack {
                Image("Logotipo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding()
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(isLoginValid ? .primary : .red)
                
                if !isLoginValid {
                    Text(loginWarning)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 4)
                }
                
                if isFieldEmpty {
                    Text("Todos los campos deben ser completados.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 4)
                }
                
                NavigationLink(destination: RegistrationUsersView()) {
                    Text("¿No tienes una cuenta? Regístrate aquí.")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                .padding(.bottom, 12)

                Button("Iniciar sesión") {
                    if isLoginInputValid() {
                        Auth.auth().signIn(withEmail: username, password: password) { result, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else {
                            print("Ingresando...")
                            isUserLoggedIn = true
                            let mainView = MainView()
                                            let navView = NavigationView {
                                                mainView
                                            }
                                            navView.navigationBarBackButtonHidden(true)
                                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: navView)
                                            
                        }
                    } //se agrega todo eso
                    } else {
                        isFieldEmpty = true
                        // Mostrar mensaje de error o realizar acciones cuando el inicio de sesión no sea válido
                    }
                }
                .padding()
                .background(Color.yellow)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()

                NavigationLink(destination: MainView(), isActive: $isUserLoggedIn) { EmptyView() } //Para que si es correcto, se dirija
            }
            .padding()
        } //Se agrega la navigation view
    }
    
    private func isLoginInputValid() -> Bool {
        return !username.isEmpty && !password.isEmpty
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct RegistrationUsersView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordValid = true
    @State private var passwordWarning = ""
    @State private var passwordsMatch = true
    @State private var passwordsMatchWarning = ""
    @State private var isFieldEmpty = false
    @State private var isUserRegistered = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Register") {
                    if isRegistrationValid() {
                        Auth.auth().createUser(withEmail: username, password: password) { result, error in
                                if let error = error {
                                    print("Error: \(error.localizedDescription)")
                                } else {
                                    print("Registro correcto.")
                                   isUserRegistered = true //se agrega
                                }
                            }
                    } else {
                        isFieldEmpty = true
                        // Mostrar mensaje de error o realizar acciones cuando el registro no sea válido
                    }
                }
                .padding()
                .background(Color.yellow)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()

                NavigationLink(destination: MainView(), isActive: $isUserRegistered) { EmptyView() } //Para que si es correcto, se dirija
            }
            .padding()
        }
    }

    private func validatePassword() {
        let passwordRegex = "^(?=.[0-9])(?=.[a-z])(?=.[A-Z])(?=.[$@$#!%?&])[A-Za-z\\d$@$#!%?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        isPasswordValid = passwordPredicate.evaluate(with: password)

        if !isPasswordValid {
            passwordWarning = "La contraseña debe tener al menos 8 caracteres y contener al menos un número, una minúscula, una mayúscula y un carácter especial."
        } else {
            passwordWarning = ""
        }
    }

    private func isRegistrationValid() -> Bool {
        return isPasswordValid && passwordsMatch && !username.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
}

struct MainView: View {
    @State private var showListView = false
    @State private var showRegistrationView = false
    @State private var showQuestionsView = false
    @State private var showRegisterView = false
    @State private var isLoggedIn = true
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Bienvenido")
                    .font(.title)
                    .padding()
                
                Spacer()
                
                Button("Lista") {
                    showListView = true
                }
                .font(.headline)
                .padding()
                .sheet(isPresented: $showListView) {
                    ListView()
                }
                
                Button("Registrar") {
                    showRegisterView = true
                }
                .font(.headline)
                .padding()
                .sheet(isPresented: $showRegisterView) {
                    RegisterView()
                }
                
                Button("Preguntas") {
                    showQuestionsView = true
                }
                .font(.headline)
                .padding()
                .sheet(isPresented: $showQuestionsView) {
                    QuestionsView()
                }
                
                Button("Cerrar Sesión") {
                    isLoggedIn = false
                }
                .font(.headline)
                .padding()
                
                Spacer()
            }
            
        }
    }
}


struct ListView: View {
    let items = [
        Item(nombre: "Juan", fraccionamiento: "Fraccionamiento A", turno: "Mañana"),
        Item(nombre: "María", fraccionamiento: "Fraccionamiento B", turno: "Tarde"),
        Item(nombre: "Pedro", fraccionamiento: "Fraccionamiento C", turno: "Noche")
    ]
    
    var body: some View {
        List(items) { item in
            VStack(alignment: .leading) {
                Text(item.nombre)
                Text(item.fraccionamiento)
                Text(item.turno)
            }
        }
        .navigationTitle("Lista")
    }
}

struct Item: Identifiable {
    let id = UUID()
    let nombre: String
    let fraccionamiento: String
    let turno: String
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}

struct RegisterView: View {
    @State private var nombre = ""
    @State private var fraccionamiento = ""
    @State private var turno = ""
    
    let fraccionamientos = ["Linda Vista", "Zibatá", "Zakia"]
    let turnos = ["24 hrs", "48 hrs"]
    
    var body: some View {
        Form {
            TextField("Nombre", text: $nombre)
            
            Picker("Fraccionamiento", selection: $fraccionamiento) {
                ForEach(fraccionamientos, id: \.self) { fraccionamiento in
                    Text(fraccionamiento)
                }
            }
            
            Picker("Turno", selection: $turno) {
                ForEach(turnos, id: \.self) { turno in
                    Text(turno)
                }
            }
        }
        .navigationTitle("Registro")
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}



struct QuestionsView: View {
    var body: some View {
        VStack {
            Text("¿Dónde puedo registrar turnos?")
                .font(.title)
                .padding()
        }
        .navigationTitle("Preguntas")
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView()
    }
}




















