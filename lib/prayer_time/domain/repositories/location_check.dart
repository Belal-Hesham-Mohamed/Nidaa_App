import 'package:hive/hive.dart';
import 'package:nidaa/core/injection_container.dart';
import 'package:nidaa/location/data/model/location_model.dart';
import 'package:nidaa/location/domain/usecase/get_current_loc_usecase.dart';

class LocationCheck {
  Future<void> checkLocation() async {
    final box = Hive.box<LocationModel>('locationBox');

    final result = await sl<GetCurrentLocation>()();

    result.fold(
      (failure) {
        // ToDo: Handle failure if needed
      },
      (location) async {
        final existingLocation = box.get('location');

        // No location saved in Hive
        if (existingLocation == null) {
          await box.put(
            'location',
            LocationModel(
              latitude: location.latitude,
              longitude: location.longitude,
              country: location.country,
              city: location.city,
            ),
          );

          return;
        }

        // Location exists → compare
        if (existingLocation.city != location.city ||
            existingLocation.country != location.country) {
          await box.put(
            'location',
            LocationModel(
              latitude: location.latitude,
              longitude: location.longitude,
              country: location.country,
              city: location.city,
            ),
          );
        }
      },
    );
  }
}