import 'dart:io';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfete/app_bloc.dart';
import 'package:ikonfete/colors.dart';
import 'package:ikonfete/di.dart';
import 'package:ikonfete/icons.dart';
import 'package:ikonfete/repository/activation_repository.dart';
import 'package:ikonfete/repository/auth_repository.dart';
import 'package:ikonfete/screen_utils.dart';
import 'package:ikonfete/screens/activation/activation_screen.dart';
import 'package:ikonfete/screens/signup/signup_profile_bloc.dart';
import 'package:ikonfete/utils/compressed_image_capture.dart';
import 'package:ikonfete/widget/form_fields.dart';
import 'package:ikonfete/widget/hud_overlay.dart';
import 'package:ikonfete/widget/ikonfete_buttons.dart';
import 'package:ikonfete/widget/overlays.dart';
import 'package:image_picker/image_picker.dart';

Widget signupProfileScreen(BuildContext context,
    {@required String name,
    @required String email,
    @required String password}) {
  return BlocProvider<SignupProfileBloc>(
    bloc: SignupProfileBloc(name: name, email: email, password: password),
    child: SignupProfileScreen(email, password),
  );
}

class SignupProfileScreen extends StatefulWidget {
  final String email, password;

  SignupProfileScreen(this.email, this.password);

  @override
  _SignupProfileScreenState createState() {
    return new _SignupProfileScreenState();
  }
}

class _SignupProfileScreenState extends State<SignupProfileScreen> {
  final formKey = GlobalKey<FormState>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appBloc = BlocProvider.of<AppBloc>(context);
    final bloc = BlocProvider.of<SignupProfileBloc>(context);

    return BlocBuilder<AppEvent, AppState>(
      bloc: appBloc,
      builder: (BuildContext ctx, AppState appState) {
        return Scaffold(
          resizeToAvoidBottomPadding: false,
          key: scaffoldKey,
          body: BlocBuilder<SignupProfileScreenEvent, SignupProfileScreenState>(
            bloc: bloc,
            builder: (context, state) {
              if (state.result != null) {
                final result = state.result;
                if (result.success) {
                  ScreenUtils.onWidgetDidBuild(() {
                    Navigator.of(context).pushReplacement(CupertinoPageRoute(
                      builder: (ctx) => activationScreen(
                          ctx,
                          result.uid,
                          widget.email,
                          widget.password),
                    ));
                  });
                } else {
                  ScreenUtils.onWidgetDidBuild(() {
                    scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(result.error),
                        backgroundColor: errorColor,
                      ),
                    );
                  });
                }
              }

              return Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewInsets.top + 40.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    OverlayBuilder(
                      child: Container(),
                      showOverlay: state.isLoading,
                      overlayBuilder: (context) => HudOverlay.getOverlay(),
                    ),
                    _buildTitleAndBackButton(context),
                    SizedBox(height: 20.0),
                    _buildIntroText(),
                    SizedBox(height: 40.0),
                    BlocBuilder<AppEvent, AppState>(
                      bloc: appBloc,
                      builder: (context, appState) {
                        return UserSignupProfileForm(
                          formKey: formKey,
                          onSaved: (String username, File profilePic,
                              Country country) {
                            bloc.dispatch(SignupProfileEntered(
                                isArtist: appState.isArtist,
                                username: username,
                                profilePicture: profilePic,
                                countryCode: country.isoCode,
                                countryName: country.name));
                          },
                        );
                      },
                    ),
                    Expanded(child: Container()),
                    _buildButton(context),
                    SizedBox(height: 40.0),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTitleAndBackButton(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "YOU",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w100),
            ),
          ],
        ),
        Navigator.of(context).canPop()
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Navigator.canPop(context)
                      ? IconButton(
                          icon: Icon(CupertinoIcons.back,
                              color: Color(0xFF181D28)),
                          onPressed: () => Navigator.of(context).maybePop(),
                        )
                      : Container(),
                ],
              )
            : Container()
      ],
    );
  }

  Widget _buildIntroText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 14.0, color: Colors.black),
        text:
            "Select a display picture and username\nthat you will be identified with.",
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PrimaryButton(
          width: screenSize.width - 80,
          height: 50.0,
          defaultColor: primaryButtonColor,
          activeColor: primaryButtonActiveColor,
          text: "PROCEED",
          // REGISTER
          onTap: () {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
            }
          },
        ),
      ],
    );
  }
}

class UserSignupProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(String, File, Country) onSaved;

  UserSignupProfileForm({@required this.formKey, @required this.onSaved});

  @override
  _UserSignupProfileFormState createState() => _UserSignupProfileFormState();
}

class _UserSignupProfileFormState extends State<UserSignupProfileForm> {
  bool _loadingPicture = false;
  File _displayPicture;
  Country _selectedCountry;
  String _username;

  FocusNode usernameFocusNode;

  @override
  void initState() {
    super.initState();
    usernameFocusNode = FocusNode();
    _selectedCountry = CountryPickerUtils.getCountryByIsoCode("ng");
  }

  @override
  Widget build(BuildContext context) {
    final uploadImageHandler = TapGestureRecognizer();
    uploadImageHandler.onTap = () {
      _chooseDisplayPicture(ImageSource.gallery);
    };

    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ProfilePictureChooser(
              onTap: () {
                _chooseDisplayPicture(ImageSource.camera);
              },
              image: _displayPicture,
              isLoadingImage: _loadingPicture,
            ),
            SizedBox(height: 10.0),
            Text("OR"),
            SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                text: "Upload Image",
                style: TextStyle(
                  color: primaryColor,
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                ),
                recognizer: uploadImageHandler,
              ),
            ),
            SizedBox(height: 40.0),
            LoginFormField(
              validator: FormFieldValidators.notEmpty("username"),
              focusNode: usernameFocusNode,
              placeholder: "Username",
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onSaved: (val) {
                _username = val.trim();
                widget.onSaved(_username, _displayPicture, _selectedCountry);
              },
              onFieldSubmitted: (val) {
                usernameFocusNode.unfocus();
              },
            ),
            SizedBox(height: 30.0),
            Text(
              "Select your country",
              style: TextStyle(fontSize: 14.0, color: Colors.black),
            ),
            SizedBox(height: 10.0),
            Material(
              child: InkWell(
                onTap: _showCountryPickerDialog,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CountryPickerUtils.getDefaultFlagImage(_selectedCountry),
                      SizedBox(width: 8.0),
                      Flexible(child: Text(_selectedCountry.name)),
                      SizedBox(width: 8.0),
                      Text("(${_selectedCountry.isoCode})"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _chooseDisplayPicture(ImageSource imageSource) async {
    setState(() {
      _loadingPicture = true;
    });
    final im = await CompressedImageCapture().takePicture(context, imageSource);
    setState(() {
      _loadingPicture = false;
      _displayPicture = im;
    });
  }

  void _showCountryPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: CountryPickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.pinkAccent,
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: Text('Select your phone code'),
              onValuePicked: (Country country) => setState(() {
                    _selectedCountry = country;
                  }),
              itemBuilder: (Country country) {
                return Row(
                  children: <Widget>[
                    CountryPickerUtils.getDefaultFlagImage(country),
                    SizedBox(width: 8.0),
                    Flexible(child: Text(country.name)),
                    SizedBox(width: 8.0),
                    Text("(${country.isoCode})"),
                  ],
                );
              },
            ),
          ),
    );
  }
}

class ProfilePictureChooser extends StatelessWidget {
  final Function onTap;
  final File image;
  final bool isLoadingImage;

  ProfilePictureChooser({
    this.onTap,
    this.image,
    this.isLoadingImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.4),
          shape: BoxShape.circle,
          image: image == null
              ? null
              : DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: image == null
                  ? ClipOval(
                      child: Icon(
                        FontAwesome5Icons.solidUser,
                        color: primaryColor.withOpacity(0.5),
                        size: 80.0,
                      ),
                    )
                  : Container(),
            ),
            Icon(
              LineAwesomeIcons.camera,
              color: Colors.white,
              size: 40.0,
            ),
            isLoadingImage
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor))
                : Container(),
          ],
        ),
      ),
    );
  }
}
