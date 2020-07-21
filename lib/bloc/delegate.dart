import 'package:bloc/bloc.dart';
import 'package:flutter_video_player/bloc/video_player_bloc.dart';

// We can extend `BlocDelegate` and override `onTransition` and `onError`
// in order to handle transitions and errors from all Blocs.
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if(transition.nextState is VideoPlayerSuccess) {
      print('\n\n');
      print('Transition currentstate' + transition.currentState.toString() + '   Transition nextstate -> ' + transition.nextState .toString());
    } else {
      print(transition);
    }
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}
