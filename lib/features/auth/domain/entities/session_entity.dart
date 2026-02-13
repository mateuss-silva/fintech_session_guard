import 'package:equatable/equatable.dart';

/// Active session domain entity.
class SessionEntity extends Equatable {
  final String id;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;
  final DateTime lastActivity;
  final DateTime createdAt;

  const SessionEntity({
    required this.id,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
    required this.lastActivity,
    required this.createdAt,
  });

  /// Whether this is the current device's session.
  bool isCurrent(String? currentDeviceId) =>
      deviceId != null && deviceId == currentDeviceId;

  @override
  List<Object?> get props => [
    id,
    deviceId,
    ipAddress,
    userAgent,
    lastActivity,
    createdAt,
  ];
}
