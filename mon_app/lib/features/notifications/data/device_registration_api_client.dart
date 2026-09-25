import '../../devices/data/device_repository.dart';
import '../application/notification_registration_service.dart';

class DeviceRegistrationApiClient implements DeviceRegistrationClient {
  DeviceRegistrationApiClient({DeviceRepository? repository})
    : _repository = repository ?? DeviceRepository();

  final DeviceRepository _repository;

  @override
  Future<void> registerDevice(DeviceRegistration registration) {
    return _repository.registerDevice(
      fcmToken: registration.fcmToken,
      platform: registration.platform,
      appVersion: registration.appVersion,
      churchId: registration.churchId,
    );
  }
}
