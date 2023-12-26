import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

String getErrorMessageFromException(dynamic error) {
  log(error.toString());
  if (error is DioException) {
    if (error.response != null && error.response?.data != null) {
      return error.response?.data['message'] ?? 'Something went wrong';
    }
    switch (error.type) {
      case DioExceptionType.cancel:
        return "Request to ThingsBoard server was cancelled";
      case DioExceptionType.badCertificate:
        return "Certificate error. Please try again";
      case DioExceptionType.badResponse:
        return "Bad response. Please try again";
      case DioExceptionType.connectionError:
        return "Server connection error. please try again later.";
      case DioExceptionType.receiveTimeout:
        return "Receive timeout in connection with ThingsBoard server";
      case DioExceptionType.sendTimeout:
        return "Send timeout in connection with ThingsBoard server";
      case DioExceptionType.unknown:
        return "Unknown error. Please try again later";
      default:
        return "Server seems to be not reachable at the moment. Please try later.";
    }
  }
  return "Unknown error";
}

String getErrorMessageFromThingsBoard(int? statusCode) {
  switch (statusCode) {
    case 400:
      return 'Bad request';
    case 404:
      return 'Resource not found';
    case 500:
      return "Internal Server Error";
    case 501:
      return "Not Implemented";
    case 502:
      return "Bad Gateway";
    case 503:
      return "Service Unavailable";
    case 504:
      return "Gateway Timeout";
    case 505:
      return "HTTP Version Not Supported";
    default:
      return 'Server seems to be not reachable at the moment. Please try later.';
  }
}

showToast(String message, [String type = 'error']) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: type == 'success' ? Colors.green : Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
