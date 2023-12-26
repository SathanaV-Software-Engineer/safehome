enum Environment { dev, prod }

class AppConfig {
  static Environment currentEnvironment = Environment.dev;
  static APIs get api => APIs.fromEnvironment(currentEnvironment);
}

class APIs {
  static String baseUrl = '';
  String register;
  String updateWatchers;
  String findUser;
  String login;
  String logout;
  String getSystemDetails;
  String updateUser;
  String addSensor;
  String removeSensor;
  String factoryReset;
  String recovery;

  APIs({
    required this.register,
    required this.updateWatchers,
    required this.findUser,
    required this.login,
    required this.logout,
    required this.getSystemDetails,
    required this.updateUser,
    required this.addSensor,
    required this.removeSensor,
    required this.factoryReset,
    required this.recovery,
  });

  factory APIs.fromEnvironment(Environment environment) {
    switch (environment) {
      case Environment.dev:
        baseUrl = 'https://c5ztwwgle5.execute-api.us-east-2.amazonaws.com';
        return APIs(
          register: '$baseUrl/api/register',
          updateWatchers: '$baseUrl/api/watchers',
          findUser: '$baseUrl/api/user?phone=',
          login: '$baseUrl/api/login',
          logout: '$baseUrl/api/logout',
          getSystemDetails: '$baseUrl/api/getSystemDetails',
          updateUser: '$baseUrl/api/updateUser',
          addSensor: '$baseUrl/api/addSensor',
          removeSensor: '$baseUrl/api/removeSensor',
          factoryReset: '$baseUrl/api/factoryReset',
          recovery: '$baseUrl/api/factoryReset',
        );
      case Environment.prod:
        baseUrl = 'https://salzerelectronics.in';
        return APIs(
          register: '$baseUrl/api/register',
          updateWatchers: '$baseUrl/api/update/watchers',
          findUser: '$baseUrl/api/user?phone=',
          login: '$baseUrl/api/login',
          logout: '$baseUrl/api/logout',
          getSystemDetails: '$baseUrl/api/getSystemDetails',
          updateUser: '$baseUrl/api/updateUser',
          addSensor: '$baseUrl/api/addSensor',
          removeSensor: '$baseUrl/api/removeSensor',
          factoryReset: '$baseUrl/api/factoryReset',
          recovery: '$baseUrl/api/factoryReset',
        );
    }
  }
}
