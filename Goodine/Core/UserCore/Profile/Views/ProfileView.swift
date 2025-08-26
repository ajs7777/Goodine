import SwiftUI
import Kingfisher

struct ProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userAuthVM: AuthViewModel
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
        ScrollView {
            VStack(spacing: 17) {
                userDetails
                
                // Affiliate Program
                Image(.apBanner)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15)
                    )
                    .onTapGesture {
                        // future tap action
                    }
            }
            .padding(.horizontal)
            
            VStack {
                
                NavigationLink {
                    MyAccountView()
                        .navigationBarBackButtonHidden()
                        .enableSwipeBackGesture()
                } label: {
                    options(title: "My Account", image: "person")
                }
                
                NavigationLink {
                    RestaurantOrdersView()
                        .navigationBarBackButtonHidden()
                        .enableSwipeBackGesture()
                } label: {
                    options(title: "My Orders", image: "bag")
                }
                
                NavigationLink {
                    PaymentsView()
                    .navigationBarBackButtonHidden()
                    .enableSwipeBackGesture()
                } label: {
                    options(title: "Payments", image: "creditcard")
                }
                
                NavigationLink {
                    AddressView(onLocationAllowed: {})
                    .navigationBarBackButtonHidden()
                    .enableSwipeBackGesture()
                } label: {
                    options(title: "Address", image: "location")
                }
                
                NavigationLink {
                    FavouriteRestaurantsView()
                    .navigationBarBackButtonHidden()
                    .enableSwipeBackGesture()
                } label: {
                    options(title: "Favourites", image: "heart")
                }
                
                NavigationLink {
                    PromoCodeView()
                    .navigationBarBackButtonHidden()
                    .enableSwipeBackGesture()
                } label: {
                    options(title: "Promocodes", image: "tag")
                }
                
                NavigationLink {
                    SettingsView()
                    .navigationBarBackButtonHidden()
                    .enableSwipeBackGesture()
                } label: {
                    options(title: "Settings", image: "gearshape")
                }
                
                Button {
                    if let url = URL(string: "https://forms.gle/bCWju4Mp5YEvcHKV8") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    options(title: "Help", image: "questionmark.circle")
                }

            }
            .foregroundStyle(.mainbw)
            .padding()
            
            
            Button {
                Task {
                    userAuthVM.signOut()
                }
            } label: {
                HStack {
                    Image(systemName: "power")
                        .foregroundStyle(.red)
                    Text("Log out")
                        .foregroundStyle(.red)
                }
                .bold()
            }
            .padding(.bottom, 30)
        } }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .bold()
                        .foregroundStyle(.mainbw)
                }
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: uploadSelectedImage) {
            ProfileImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func uploadSelectedImage() {
        guard let image = selectedImage else { return }
        Task {
            await userAuthVM.uploadProfileImage(image)
        }
    }
}

#Preview {
        ProfileView()
            .environmentObject(AuthViewModel())
    
}

extension ProfileView {
    private var userDetails: some View {
        HStack {
            VStack(alignment: .leading) {
                if let user = userAuthVM.userdata {
                    Text(user.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.mainbw)
                    Text(user.phoneNumber)
                        .foregroundStyle(.gray)
                }
            }
            Spacer()
            
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = userAuthVM.userdata?.profileImageURL, let url = URL(string: imageUrl) {
                    // Profile image from Firebase using Kingfisher
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else {
                    // Placeholder
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color(.systemGray3))
                }
                
                Button {
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.callout)
                        .foregroundStyle(.mainbw)
                        .padding(6)
                        .background(Color.mainInvert)
                        .clipShape(Circle())
                }
                .offset(x: 5, y: 5)
            }
            .padding()
        }
    }
}

//options
struct options : View {
    
    let title : String
    let image : String
    
    var body: some View{
        HStack(spacing: 20.0){
            Image(systemName: image)
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
                .fontWeight(.semibold)
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
                
        } .padding(12)
    }
}
