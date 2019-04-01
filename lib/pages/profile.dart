import 'package:flutter/material.dart';
import 'package:sonar_frontend/model/profile_model.dart';
import 'package:sonar_frontend/utils/profile_util.dart';
import 'package:sonar_frontend/utils/color_builder.dart';

class ProfilePage extends StatefulWidget {
  final ProfileStorage profileStorage;
  ProfilePage({Key key, this.title, this.profileStorage}) : super(key: key);

  final String title;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  ProfileModel _profile;
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final snapchatController = TextEditingController();
  final facebookController = TextEditingController();
  final twitterController = TextEditingController();
  final instagramController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get Profile from Disk
    widget.profileStorage.readProfile().then((ProfileModel value) {
      setState(() {
        _profile = value;
        // Check if Profile is Empty
        if (!_profile.isEmpty()) {
          phoneController.text = _profile.phone;
          nameController.text = _profile.name;
          emailController.text = _profile.email;
          snapchatController.text = _profile.snapchat;
          facebookController.text = _profile.facebook;
          twitterController.text = _profile.twitter;
          instagramController.text = _profile.instagram;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 0.5,
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Center(
                  child: Padding(
                      child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      "http://i.pravatar.cc/100")))),
                      padding: EdgeInsets.only(top: 10)),
                ),
                decoration: BoxDecoration(color: Colors.white54),
              ),
              Form(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(hintText: 'Name'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your name';
                        }
                      },
                      onSaved: (val) => setState(() => _profile.name = val),
                    ),
                    TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(hintText: 'Phone'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your name';
                          }
                        },
                        onSaved: (val) => setState(() => _profile.phone = val)),
                    TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(hintText: 'Email'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your name';
                          }
                        },
                        onSaved: (val) => setState(() => _profile.email = val)),
                    TextFormField(
                        controller: snapchatController,
                        decoration: InputDecoration(hintText: 'Snapchat'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your name';
                          }
                        },
                        onSaved: (val) => setState(() => _profile.snapchat = val)),
                    TextFormField(
                        controller: facebookController,
                        decoration: InputDecoration(hintText: 'Facebook'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your name';
                          }
                        },
                        onSaved: (val) => setState(() => _profile.facebook = val)),
                    TextFormField(
                        controller: twitterController,
                        decoration: InputDecoration(hintText: 'Twitter'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your name';
                          }
                        },
                        onSaved: (val) => setState(() => _profile.twitter = val)),
                    TextFormField(
                        controller: instagramController,
                        decoration: InputDecoration(hintText: 'Instagram'),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your name';
                          }
                        },
                        onSaved: (val) => setState(() => _profile.instagram = val)),
                  ])),
              RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _confirmSave();
                    }
                  },
                  child: Text('Save')),
            ]));
  }


   void _confirmSave() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm Changes?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Save"),
              onPressed: () {
                _formKey.currentState.save();
                widget.profileStorage.writeProfile(_profile);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
