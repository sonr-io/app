import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sonar_app/bloc/bloc.dart';
import 'package:sonar_app/models/models.dart';
import 'package:sonar_app/repository/repository.dart';
import 'package:sonar_app/core/core.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(null);

  // Initialize References
  Profile currentProfile;

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is UpdateProfile) {
      yield* _mapUpdateProfileState(event);
    } else if (event is CheckStatus) {
      yield* _mapCheckStatusState(event);
    }
  }

// ***********************
// ** UpdateProfile Event **
// *************************
  Stream<UserState> _mapUpdateProfileState(
      UpdateProfile updateProfileEvent) async* {
    // Save to Box
    await localData.updateProfile(updateProfileEvent.data);

    // Update Reference
    this.currentProfile = updateProfileEvent.data;

    // Profile Ready
    yield Online(currentProfile);
  }

// ***********************
// ** CheckStatus Event **
// ***********************
  Stream<UserState> _mapCheckStatusState(
      CheckStatus checkLocalStatusEvent) async* {
    // Check Status
    var profile = await localData.getProfile();

    // Create Delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // No Profile
    if (profile == null) {
      // Update Reference
      this.currentProfile = null;

      // Change State
      yield Offline();
    }
    // Profile Found
    else {
      // Update Reference
      this.currentProfile = profile;

      // Profile Ready
      yield Online(currentProfile);
    }
  }
}
