class Endpoints {
  Endpoints._();

  // base url
  static const baseUrl = "https://api.stripe.com/v1";
  static const stripePay = "/payment_intents";
  // receiveTimeout
  static const int receiveTimeout = 50000;

  // connectTimeout
  static const int connectionTimeout = 50000;

}
