Build a complete modern responsive website called:

SMART BLOOD DONATION MANAGEMENT SYSTEM – VitalPulse

The website should be a polished frontend prototype for a smart blood donation coordination platform connecting Donors, Patients/Recipients, Hospitals, Blood Banks, and Admins.

IMPORTANT:
- This is a frontend-only prototype.
- Do NOT create a real backend.
- Do NOT implement real authentication.
- Use realistic mock/local data.
- Structure the code so a backend can be integrated later.
- Do not leave blank pages or placeholder sections.
- Every major button, card, filter, tab, modal, navigation item, and interaction should work using mock data.
- The website should feel like a real production application.

==================================================
DESIGN & UI/UX
==================================================

Use a premium, clean, modern healthcare interface.

Color combination:
- Sky Blue / Primary Blue
- White
- Black / Dark Gray
- Very light blue backgrounds where appropriate

Design should communicate:
- Trust
- Healthcare
- Emergency response
- Cleanliness
- Reliability
- Modern technology

Use smooth animations and transitions throughout the application.

Target a very smooth 120Hz/120fps-capable experience where the device/browser supports it.

Use a strong iOS-inspired visual language:
- Rounded cards
- Soft shadows
- Smooth transitions
- Clean typography
- Spacious layouts
- Minimal interface
- Premium navigation
- Modern glass/blur effects where appropriate

IMPORTANT:
Do NOT use Material Design visual language.

Do NOT use Material Icons.

Use Lucide icons or another clean modern icon system instead, with an iOS/Cupertino-inspired appearance.

The website must be fully responsive for:
- Desktop
- Tablet
- Mobile

==================================================
SPLASH / LOADING EXPERIENCE
==================================================

Create a professional splash/loading screen for VitalPulse.

Include:
- Application logo
- VitalPulse name
- Short tagline related to blood donation
- Smooth entrance animation
- Smooth transition into the main application

==================================================
MAIN NAVIGATION
==================================================

Create a responsive navigation system.

Desktop:
- Left sidebar or modern dashboard navigation

Mobile:
- Bottom navigation

Main navigation sections:

1. Home
2. Blood Search / Find Blood
3. History
4. Notifications
5. Settings

Provide clear active-state indicators and smooth navigation animations.

==================================================
HOME SCREEN
==================================================

Create a visually strong dashboard-style Home screen.

Top section:
- Welcome message
- User profile/avatar
- Notification icon
- Current location
- Quick emergency SOS button

Main action cards:

1. Find Blood
2. Request Blood
3. Emergency SOS
4. Donate Blood
5. Find Nearby Blood Banks
6. Donation Camps

Blood availability section:

Display blood groups:

A+
A-
B+
B-
AB+
AB-
O+
O-

Each blood group should show:
- Available units
- Availability status
- Low-stock indicator when applicable

Use visual status indicators such as:
- Available
- Limited
- Low Stock
- Critical

==================================================
BLOOD SEARCH
==================================================

Create a Find Blood page.

Users should be able to search using:

- Blood Group
- Location
- Distance
- Availability
- Blood Bank
- Hospital

Display search results as cards containing:

- Blood group
- Available units
- Blood bank/hospital name
- Distance
- Location
- Availability status
- Last updated information
- View Details button
- Get Directions button

Add map-style location visualization using mock data.

==================================================
SMART DONOR MATCHING
==================================================

Create a Smart Donor Matching feature.

When a blood request is created, show suitable donor matches based on:

- Blood group compatibility
- Location/distance
- Donor availability
- Donation eligibility
- Previous donation information

Display matching donors using cards.

Each donor card should show:

- Donor name
- Blood group
- Distance
- Availability status
- Eligibility status
- Last donation
- Compatibility indicator
- Contact/Request button

Show a match percentage or compatibility score using mock data.

==================================================
EMERGENCY SOS
==================================================

Create a highly visible Emergency SOS feature.

The user should be able to create an emergency blood request by selecting:

- Required blood group
- Required units
- Location
- Hospital
- Urgency level
- Required date/time
- Additional notes

Use clear emergency UI without making the interface visually overwhelming.

After submitting:

Show:
- Emergency request ID
- Request status
- Matching donors
- Nearby blood banks
- Nearby hospitals
- Notification status

Simulate instant emergency notifications using toast/alert components.

==================================================
PATIENT / RECIPIENT DASHBOARD
==================================================

Create a Patient/Recipient dashboard.

Include:

- Blood request summary
- Current requests
- Emergency requests
- Required blood group
- Nearby blood banks
- Available blood units
- Compatible donor matches
- Request status
- Request history
- Notifications

Request statuses:

- Pending
- Matching
- Blood Found
- Confirmed
- Completed
- Cancelled

==================================================
DONOR DASHBOARD
==================================================

Create a Donor dashboard.

Display:

- Donor blood group
- Availability status
- Last donation date
- Next eligible donation date
- Donation count
- Donation history
- Upcoming appointments
- Emergency blood requests
- Notifications
- Digital donor card
- Nearby blood donation camps

Allow the donor to toggle:

Available / Not Available

Create a clean donor profile section.

==================================================
DIGITAL DONOR CARD
==================================================

Create a digital donor card.

Include:

- Donor name
- Blood group
- Donor ID
- Donation count
- Last donation
- Eligibility status
- QR-style visual identifier

The QR identifier can be mock/static for the frontend prototype.

==================================================
HOSPITAL DASHBOARD
==================================================

Create a Hospital dashboard.

Include:

- Total blood requests
- Emergency requests
- Current blood inventory
- Low-stock alerts
- Donor search
- Patient requests
- Appointments
- Recent activities
- Reports

Hospital users should be able to view:

- Blood group availability
- Request priority
- Request status
- Matched donors
- Nearby blood banks

==================================================
BLOOD BANK DASHBOARD
==================================================

Create a Blood Bank dashboard.

Inventory should be displayed blood-group-wise.

Show:

- Available units
- Reserved units
- Total units
- Low-stock status
- Near-expiry units

Include:

- Donation records
- Blood requests
- Donor records
- Blood transfers
- Inventory management
- Expiry alerts
- Low-stock alerts
- Reports

Create charts for inventory distribution.

==================================================
ADMIN DASHBOARD
==================================================

Create a complete Admin dashboard.

Top statistics:

- Total Donors
- Total Patients
- Total Hospitals
- Total Blood Banks
- Total Blood Requests
- Emergency Requests
- Total Donations
- Available Blood Units

Analytics:

- Blood group demand
- Donation statistics
- Emergency request statistics
- Blood availability
- Monthly requests
- Monthly donations
- Blood group distribution

Use beautiful interactive charts.

Admin management sections:

- Users
- Donors
- Patients
- Hospitals
- Blood Banks
- Blood Requests
- Emergency Requests
- Donation Camps
- Notifications

Provide search, filters, status badges, and action menus.

==================================================
HISTORY SCREEN
==================================================

Create a complete History screen.

Store mock history for:

- Blood requests
- Emergency requests
- Donations
- Appointments
- Blood searches
- Other important activities

Each history item should contain:

- Date
- Time
- Activity type
- Blood group
- Location
- Status
- Details

Under the app bar, create filters:

- Date
- Blood Group
- Request Type
- Status
- Activity Type

Add analytics and data visualization.

Charts can show:

- Donations over time
- Blood requests over time
- Emergency requests
- Blood group demand
- Successful donations

Use interactive chart cards.

==================================================
DONATION CAMPS
==================================================

Create a Donation Camps section.

Display nearby camps with:

- Camp name
- Date
- Time
- Location
- Organizer
- Available slots
- Distance
- Register button
- View Details button

Allow users to book/register for a camp using mock interactions.

==================================================
APPOINTMENT SYSTEM
==================================================

Create an appointment booking experience.

Donors should be able to:

- Select donation center
- Select date
- Select time
- Confirm appointment

Display:

- Upcoming appointments
- Completed appointments
- Cancelled appointments

Use mock data and local state.

==================================================
NOTIFICATIONS
==================================================

Create a notifications center.

Notification types:

- Emergency blood request
- Blood request update
- Donor match
- Appointment reminder
- Donation reminder
- Low blood stock
- Expiring blood alert
- Donation camp notification

Use notification badges and toast notifications.

Emergency notifications should have higher visual priority.

==================================================
MAPS & LOCATION
==================================================

Create a location-based interface using mock location data.

Show:

- Nearby blood banks
- Hospitals
- Donation camps
- Suitable donors

Include:

- Distance
- Location
- Get Directions action

If an actual map API is not configured, create a polished mock map interface rather than leaving an empty section.

==================================================
BLOOD COMPATIBILITY CHECKER
==================================================

Create a Blood Compatibility Checker.

Allow users to select:

- Donor blood group
- Recipient blood group

Display whether the combination is compatible.

Show the result using a clean visual card.

Use medically appropriate blood-group compatibility rules.

==================================================
SETTINGS SCREEN
==================================================

Create a Settings page.

Sections:

Appearance:
- Light Mode
- Dark Mode
- System Mode

Notifications:
- Emergency Alerts
- Blood Request Alerts
- Appointment Reminders
- Donation Reminders

Other:

- Terms & Conditions
- Privacy Policy
- About VitalPulse
- Help & Support
- Application Version

Create a polished About section with the application logo and description.

==================================================
ADS INTEGRATION
==================================================

Add an ad-ready UI structure.

Place a small banner advertisement area:

- At the bottom
- Above the mobile bottom navigation
- Subtle and non-intrusive
- Must not cover content
- Must not interfere with navigation

Create an interstitial-ad simulation component for the frontend prototype.

Important:
Do NOT make the interface unusable because of ads.

For the prototype, simulate ad behavior using mock components rather than requiring a real ad network.

Use reasonable frequency controls and never trigger an interstitial repeatedly without user interaction.

==================================================
LOCAL DATA
==================================================

Since there is no backend:

Use realistic mock/local data for:

- Donors
- Patients
- Hospitals
- Blood banks
- Blood inventory
- Blood requests
- Emergency requests
- Donations
- Appointments
- Camps
- Notifications
- History

Use local state/local storage where appropriate so interactions feel persistent during use.

==================================================
INTERACTIONS
==================================================

Implement working frontend interactions for:

- Navigation
- Search
- Filters
- Sorting
- Blood group selection
- Emergency request creation
- Blood request creation
- Donor matching
- Appointment booking
- Camp registration
- Availability toggle
- Dark/light mode
- Notifications
- Toast messages
- Modals
- Dropdowns
- Tabs
- Charts
- History filtering

Do not create buttons that do nothing.

==================================================
ANIMATIONS
==================================================

Use smooth animations for:

- Page transitions
- Cards
- Modals
- Bottom navigation
- Sidebar
- Toast notifications
- Charts
- Loading states
- Emergency request confirmation
- Search results
- Dashboard statistics

Animations should be fast, smooth and professional.

Avoid excessive animation.

==================================================
RESPONSIVE DESIGN
==================================================

Desktop:
- Full dashboard layout
- Sidebar navigation
- Multi-column cards
- Large analytics area

Tablet:
- Adaptive grid
- Collapsible navigation

Mobile:
- Bottom navigation
- Stacked cards
- Mobile-friendly forms
- Touch-friendly buttons
- Compact charts
- Floating Emergency SOS action

Make sure nothing overflows horizontally.

==================================================
TECHNICAL REQUIREMENTS
==================================================

Use a modern frontend stack suitable for Antigravity.

Preferred:
- React
- TypeScript
- Tailwind CSS
- Reusable components
- Local/mock data
- Clean component architecture

Use modular components such as:

- Navbar
- Sidebar
- BottomNavigation
- DashboardCard
- BloodGroupCard
- EmergencySOS
- BloodRequestCard
- DonorCard
- BloodBankCard
- NotificationToast
- Modal
- FilterBar
- ChartCard
- StatusBadge
- AppointmentCard
- CampCard

Keep the architecture backend-ready.

==================================================
FINAL REQUIREMENT
==================================================

The final website should look and feel like a real smart healthcare platform, not a basic college-project template.

The primary purpose is:

SMART BLOOD DONATION COORDINATION

Focus strongly on:

1. Smart donor matching
2. Emergency blood requests
3. Blood availability
4. Blood bank coordination
5. Hospital coordination
6. Donor management
7. Donation tracking
8. Location-based discovery
9. Notifications
10. Analytics

Create realistic sample data and make the entire frontend visually complete.

Do not remove any of the above features.

Do not use Material Icons.

Do not use Material Design components.

Maintain a clean iOS-inspired healthcare design with sky blue, white and black as the primary visual palette.

Build the complete working frontend now.