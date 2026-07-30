import 'ui_utility.dart';

class ApiCallListener {
  const ApiCallListener({
    this.onSuccess,
    this.onError,
    this.onCompleted,
  });
  final Function()? onSuccess;
  final Function(String error)? onError;
  final Function()? onCompleted;

  void call({String? error}) {
    if (error == null) {
      onSuccess?.call();
    } else {
      onError?.call("error: $error");
      UiUtility.showToast(error, isError: true);
    }
    onCompleted?.call();
  }
}
