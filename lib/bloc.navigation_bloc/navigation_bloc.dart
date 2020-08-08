import 'package:bloc/bloc.dart';
import 'package:sidebar_animation/pages/profilePage.dart';
import '../pages/gameEntryPage.dart';
import '../pages/statisticsPage.dart';
import '../pages/profilePage.dart';
import '../pages/homePage.dart';

enum NavigationEvents {
  HomePageClickedEvent,
  GameEntryClickedEvent,
  StatisticsClickedEvent,
  ProfileClickedEvent
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  @override
  NavigationStates get initialState => HomePage();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.HomePageClickedEvent:
        yield HomePage();
        break;
      case NavigationEvents.GameEntryClickedEvent:
        yield GameEntryPage();
        break;
      case NavigationEvents.StatisticsClickedEvent:
        yield StatisticsPage();
        break;
      case NavigationEvents.ProfileClickedEvent:
        yield ProfilePage();
        break;
    }
  }
}
