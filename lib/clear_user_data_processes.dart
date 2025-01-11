//Cancel background tasks
import 'package:workmanager/workmanager.dart';


class ClearUserDataProcess{
clearJobs() {
Workmanager().cancelAll(); //cancelByTag('tokenRefresher');
// Cancel the token refresh timers
//final TokenRefresher tokenRefresher = GetIt.instance.get<TokenRefresher>();
//tokenRefresher.cancelTimers();
}
}