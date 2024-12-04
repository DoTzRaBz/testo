import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:myapp/utils/size.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/database_helper.dart';
import 'package:myapp/models/POI.dart';
import 'package:myapp/edit_poi_screen.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OSMFlutterMap extends StatefulWidget {
  final bool isAdminOrStaff;

  const OSMFlutterMap({Key? key, required this.isAdminOrStaff})
      : super(key: key);

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  List<PointOfInterest> _pois = [];
  bool _isLoading = true;
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadPOIs();
  }

  Future<void> _loadPOIs() async {
    try {
      List<PointOfInterest> pois = await DatabaseHelper().getAllPOIs();
      setState(() {
        _pois = pois;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load locations. Please try again.',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Peta Lokasi',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TahuraColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoadingState() : _buildMap(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: TahuraColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: TahuraColors.primary,
            ),
            SizedBox(height: Sizes.medium),
            Text(
              'Loading Map...',
              style: TahuraTextStyles.bodyText,
            ),
          ],
        ),
      ).animate().fadeIn(duration: TahuraAnimations.medium),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(-6.858110, 107.630884),
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: _pois.map((poi) {
            return Marker(
              point: LatLng(poi.latitude, poi.longitude),
              width: Sizes.iconXLarge,
              height: Sizes.iconXLarge,
              child: _buildMarker(poi),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarker(PointOfInterest poi) {
    return GestureDetector(
      onTap: () => _showPopup(context, poi),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: TahuraShadows.medium,
        ),
        child: Icon(
          Icons.location_on,
          size: Sizes.iconXLarge,
          color: TahuraColors.error,
        ),
      ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
    );
  }

  void _showPopup(BuildContext context, PointOfInterest poi) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: ScreenUtils.getResponsiveHeight(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Sizes.radiusLarge),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(poi),
              _buildInfoSection(poi),
              if (widget.isAdminOrStaff) _buildAdminActions(poi),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: TahuraAnimations.medium)
          .slideY(begin: 1, end: 0),
    );
  }

  Widget _buildImageSection(PointOfInterest poi) {
    return Container(
      height: ScreenUtils.getResponsiveHeight(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Sizes.radiusLarge),
        ),
        image: DecorationImage(
          image: AssetImage(poi.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoSection(PointOfInterest poi) {
    return Padding(
      padding: EdgeInsets.all(Sizes.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poi.name,
            style: TahuraTextStyles.screenTitle.copyWith(color: Colors.black),
          ),
          SizedBox(height: Sizes.small),
          Text(
            poi.description,
            style: TahuraTextStyles.bodyText.copyWith(color: Colors.black87),
          ),
          SizedBox(height: Sizes.medium),
          ElevatedButton.icon(
            onPressed: () =>
                _launchMapsUrl(LatLng(poi.latitude, poi.longitude)),
            style: TahuraButtons.primaryButton,
            icon: Icon(Icons.directions),
            label: Text('Get Directions', style: TahuraTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(PointOfInterest poi) {
    return Padding(
      padding: EdgeInsets.all(Sizes.medium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _editPOI(poi);
            },
            style: TahuraButtons.secondaryButton,
            icon: Icon(Icons.edit),
            label: Text('Edit', style: TahuraTextStyles.buttonText),
          ),
          ElevatedButton.icon(
            onPressed: () => _confirmDelete(poi),
            style: ElevatedButton.styleFrom(
              backgroundColor: TahuraColors.error,
              foregroundColor: Colors.white,
            ),
            icon: Icon(Icons.delete),
            label: Text('Delete', style: TahuraTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  void _editPOI(PointOfInterest poi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPOIScreen(poi: poi),
      ),
    ).then((result) {
      if (result == true) {
        _loadPOIs();
      }
    });
  }

  void _confirmDelete(PointOfInterest poi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${poi.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper().deletePOI(poi.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
              }
              _loadPOIs();
            },
            style: TextButton.styleFrom(
              foregroundColor: TahuraColors.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _launchMapsUrl(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not launch maps. Please try again.',
              style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
            ),
            backgroundColor: TahuraColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(Sizes.medium),
          ),
        );
      }
    }
  }
}
