import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/event.dart';
import 'package:myapp/utils/size.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/screen_utils.dart';
import 'package:myapp/utils/style.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class EventScreen extends StatefulWidget {
  final bool isAdminOrStaff;

  const EventScreen({Key? key, required this.isAdminOrStaff}) : super(key: key);

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _dbHelper = DatabaseHelper();
  List<Event> _eventsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
    _addInitialEvents();
  }

  Future<void> _addInitialEvents() async {
    await _dbHelper.insertEvent(
      'Hutan Menyala',
      'Acara spektakuler dengan pertunjukan cahaya di hutan',
      'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura9.png',
      DateTime(2024, 12, 12),
      location: 'Area Utama Tahura',
      maxParticipants: 1000,
    );
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events =
          await _dbHelper.getEventsByDate(_selectedDay ?? DateTime.now());
      setState(() {
        _eventsList = events
            .map((e) => Event(
                  title: e['title'],
                  description: e['description'],
                  imageUrl: e['image_url'],
                  date: DateTime.parse(e['date']),
                ))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Failed to load events. Please try again.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
        ),
        backgroundColor: TahuraColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(Sizes.medium),
      ),
    );
  }

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final maxParticipantsController = TextEditingController();
    DateTime? selectedDate;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Add New Event',
            style: TahuraTextStyles.screenTitle.copyWith(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: titleController,
                  label: 'Event Title',
                  icon: Icons.event,
                ),
                SizedBox(height: Sizes.medium),
                _buildDialogTextField(
                  controller: descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                SizedBox(height: Sizes.medium),
                _buildDialogTextField(
                  controller: locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                ),
                SizedBox(height: Sizes.medium),
                _buildDialogTextField(
                  controller: maxParticipantsController,
                  label: 'Max Participants',
                  icon: Icons.group,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: Sizes.medium),
                _buildDateSelector(
                  selectedDate,
                  (date) => setState(() => selectedDate = date),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TahuraTextStyles.bodyText.copyWith(
                  color: TahuraColors.error,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    selectedDate == null) {
                  _showError('Please fill all required fields');
                  return;
                }
                Navigator.pop(context, {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'date': selectedDate,
                  'location': locationController.text,
                  'maxParticipants':
                      int.tryParse(maxParticipantsController.text),
                });
              },
              style: TahuraButtons.primaryButton,
              child: Text(
                'Save',
                style: TahuraTextStyles.buttonText,
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        await _dbHelper.insertEvent(
          result['title'],
          result['description'],
          'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura9.png',
          result['date'],
          location: result['location'],
          maxParticipants: result['maxParticipants'],
        );
        await _loadEvents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Event successfully added!',
                style: TahuraTextStyles.bodyText.copyWith(color: Colors.white),
              ),
              backgroundColor: TahuraColors.success,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(Sizes.medium),
            ),
          );
        }
      } catch (e) {
        _showError('Failed to add event. Please try again.');
      }
    }
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: TahuraInputDecorations.defaultInput.copyWith(
        labelText: label,
        prefixIcon: Icon(icon, color: TahuraColors.primary),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildDateSelector(
      DateTime? selectedDate, Function(DateTime) onSelect) {
    return ListTile(
      leading: Icon(Icons.calendar_today, color: TahuraColors.primary),
      title: Text(
        selectedDate != null
            ? DateFormat('dd MMM yyyy').format(selectedDate)
            : 'Select Date',
        style: TahuraTextStyles.bodyText.copyWith(color: Colors.black),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2025),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: TahuraColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tahura Events',
          style: TahuraTextStyles.appBarTitle,
        )
            .animate()
            .fadeIn(duration: TahuraAnimations.medium)
            .slideX(begin: -0.2, end: 0),
        actions: [
          if (widget.isAdminOrStaff)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _showAddEventDialog,
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideX(begin: 0.2, end: 0),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(Sizes.medium),
            height: ScreenUtils.getResponsiveHeight(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Sizes.radiusLarge),
            ),
          ),
          Container(
            margin: EdgeInsets.all(Sizes.medium),
            height: ScreenUtils.getResponsiveHeight(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Sizes.radiusLarge),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildCalendar(),
        _buildEventsList(),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: EdgeInsets.all(Sizes.medium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(Sizes.radiusLarge),
        boxShadow: TahuraShadows.medium,
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) => _getEventsForDay(day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadEvents();
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: TahuraColors.primary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: TahuraColors.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: TahuraColors.error,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          titleTextStyle: TahuraTextStyles.screenTitle.copyWith(
            color: Colors.black,
          ),
          formatButtonVisible: false,
        ),
      ),
    ).animate().fadeIn(duration: TahuraAnimations.medium).scale();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _eventsList.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(Sizes.medium),
        itemCount: events.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => _buildEventCard(events[index], index),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: Sizes.iconXLarge * 2,
              color: Colors.white54,
            ).animate().fadeIn(duration: TahuraAnimations.medium).scale(),
            SizedBox(height: Sizes.medium),
            Text(
              'No Events Today',
              style: TahuraTextStyles.screenTitle,
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideY(begin: 0.2, end: 0),
            Text(
              'Select another date or add a new event',
              style: TahuraTextStyles.bodyText,
            )
                .animate()
                .fadeIn(duration: TahuraAnimations.medium)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: Sizes.medium),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
      ),
      color: Colors.white.withOpacity(0.9),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(Sizes.radiusMedium),
              ),
              child: Image.asset(
                event.imageUrl ??
                    'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura9.png',
                height: ScreenUtils.getResponsiveHeight(20),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Sizes.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TahuraTextStyles.screenTitle.copyWith(
                      color: Colors.black,
                      fontSize: Sizes.fontLarge,
                    ),
                  ),
                  SizedBox(height: Sizes.small),
                  Text(
                    event.description,
                    style: TahuraTextStyles.bodyText.copyWith(
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Sizes.small),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: Sizes.iconSmall,
                        color: TahuraColors.primary,
                      ),
                      SizedBox(width: Sizes.small),
                      Text(
                        DateFormat('dd MMM yyyy HH:mm').format(event.date),
                        style: TahuraTextStyles.bodyText.copyWith(
                          color: TahuraColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: TahuraAnimations.medium,
          delay: Duration(milliseconds: 100 * index),
        )
        .slideX(begin: 0.2, end: 0);
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: ScreenUtils.getResponsiveHeight(70),
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
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Sizes.radiusLarge),
                ),
                child: Image.asset(
                  event.imageUrl ??
                      'C:/Users/Nikolaus Franz/Documents/tahura_project/lib/assets/tahura9.png',
                  height: ScreenUtils.getResponsiveHeight(30),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Sizes.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TahuraTextStyles.screenTitle.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: Sizes.medium),
                    Text(
                      event.description,
                      style: TahuraTextStyles.bodyText.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: Sizes.large),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: TahuraColors.primary,
                        ),
                        SizedBox(width: Sizes.medium),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy HH:mm')
                              .format(event.date),
                          style: TahuraTextStyles.bodyText.copyWith(
                            color: TahuraColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (widget.isAdminOrStaff) ...[
                      SizedBox(height: Sizes.large),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement edit functionality
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Edit Event'),
                            style: TahuraButtons.secondaryButton,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement delete functionality
                            },
                            icon: Icon(Icons.delete),
                            label: Text('Delete Event'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TahuraColors.error,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
